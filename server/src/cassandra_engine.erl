-module(cassandra_engine).
-export([init/0, execute_cql/1, insert_wide_row/4, query_partition/2]).

-define(TABLE, yoda_cassandra_partitions).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, ordered_set, {read_concurrency, true}, {write_concurrency, true}]),
            % Seed wide-column partition data
            insert_wide_row(<<"telemetry_by_device">>, <<"device_alpha">>, erlang:system_time(second) - 60, <<"{\"temp\":42.5,\"voltage\":12.1}">>),
            insert_wide_row(<<"telemetry_by_device">>, <<"device_alpha">>, erlang:system_time(second), <<"{\"temp\":44.1,\"voltage\":12.2}">>),
            insert_wide_row(<<"telemetry_by_device">>, <<"device_beta">>, erlang:system_time(second), <<"{\"temp\":89.4,\"voltage\":13.8}">>);
        _ -> ok
    end,
    ok.

calculate_token(PartitionKeyBin) ->
    erlang:phash2(PartitionKeyBin, 16#FFFFFFFF).

insert_wide_row(TableBin, PartitionKeyBin, ClusteringTime, ValueJsonBin) ->
    Token = calculate_token(PartitionKeyBin),
    Key = {TableBin, Token, PartitionKeyBin, ClusteringTime},
    ets:insert(?TABLE, {Key, ValueJsonBin}),
    Token.

query_partition(TableBin, PartitionKeyBin) ->
    Token = calculate_token(PartitionKeyBin),
    All = ets:tab2list(?TABLE),
    Matching = [ {Time, Val} || {{T, Tok, PK, Time}, Val} <- All, T =:= TableBin, Tok =:= Token, PK =:= PartitionKeyBin ],
    lists:reverse(lists:keysort(1, Matching)).

execute_cql(CqlBin) ->
    CqlStr = binary_to_list(CqlBin),
    Trimmed = string:trim(CqlStr),
    Upper = string:to_upper(Trimmed),
    
    StartUs = erlang:system_time(microsecond),
    
    case re:run(Upper, "^INSERT\\s+INTO\\s+([A-Z0-9_]+)", [{capture, [1], list}]) of
        {match, [Table]} ->
            PK = case re:run(Trimmed, "VALUES\\s*\\(\\s*'([^']+)'", [{capture, [1], list}]) of
                {match, [P]} -> list_to_binary(P);
                _ -> <<"default_device">>
            end,
            Token = insert_wide_row(list_to_binary(string:to_lower(Table)), PK, erlang:system_time(second), CqlBin),
            ElapsedUs = max(5, erlang:system_time(microsecond) - StartUs),
            list_to_binary(io_lib:format("{\"keyspace\":\"yoda_timeseries\",\"table\":\"~s\",\"cql_status\":\"APPLIED\",\"token\":~p,\"consistency\":\"LOCAL_QUORUM\",\"latency_us\":~p}",
                                         [Table, Token, ElapsedUs]));
        _ ->
            PK = case re:run(Trimmed, "WHERE\\s+([a-zA-Z0-9_]+)\\s*=\\s*'([^']+)'", [{capture, [2], list}]) of
                {match, [P]} -> list_to_binary(P);
                _ -> <<"device_alpha">>
            end,
            Table = case re:run(Trimmed, "FROM\\s+([a-zA-Z0-9_]+)", [{capture, [1], list}]) of
                {match, [T]} -> list_to_binary(string:to_lower(T));
                _ -> <<"telemetry_by_device">>
            end,
            Rows = query_partition(Table, PK),
            Token = calculate_token(PK),
            ElapsedUs = max(5, erlang:system_time(microsecond) - StartUs),
            
            FormattedRows = [ io_lib:format("{\"clustering_time\":~p,\"data\":~s}", [Time, binary_to_list(Val)]) || {Time, Val} <- Rows ],
            Result = io_lib:format("{\"keyspace\":\"yoda_timeseries\",\"table\":\"~s\",\"partition_key\":\"~s\",\"token\":~p,\"consistency\":\"LOCAL_QUORUM\",\"latency_us\":~p,\"rows\":[~s]}",
                                   [binary_to_list(Table), binary_to_list(PK), Token, ElapsedUs, string:join(FormattedRows, ",")]),
            list_to_binary(Result)
    end.
