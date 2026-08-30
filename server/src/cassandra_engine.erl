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
    db_manager:simulate_db(<<"Scylla_Cassandra">>, CqlBin).
