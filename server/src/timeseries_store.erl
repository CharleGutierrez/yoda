-module(timeseries_store).
-export([init/0, record_point/2, record_raw/1, query_range/2, get_aggregates/2, get_timeseries_json/1, get_stats_json/0, get_total_points/0]).

-define(TABLE, yoda_timeseries_table).
-define(MAX_POINTS, 10000).

init() ->
    case ets:info(?TABLE) of
        undefined ->
            ets:new(?TABLE, [named_table, public, ordered_set, {read_concurrency, true}, {write_concurrency, true}]);
        _ ->
            ok
    end,
    ok.

record_point(SensorBin, Value) when is_number(Value) ->
    NowMs = erlang:system_time(millisecond),
    Sensor = if is_binary(SensorBin) -> SensorBin; is_list(SensorBin) -> list_to_binary(SensorBin); true -> <<"default">> end,
    % Unique key {NowMs, erlang:unique_integer([monotonic])}
    Key = {NowMs, erlang:unique_integer([monotonic])},
    ets:insert(?TABLE, {Key, Sensor, float(Value)}),
    % Bound size
    case ets:info(?TABLE, size) of
        Size when Size > ?MAX_POINTS ->
            FirstKey = ets:first(?TABLE),
            ets:delete(?TABLE, FirstKey);
        _ ->
            ok
    end,
    ok;
record_point(_, _) ->
    ok.

record_raw(MsgBin) ->
    Msg = if is_binary(MsgBin) -> binary_to_list(MsgBin); is_list(MsgBin) -> MsgBin; true -> "" end,
    % Extract sensor name and numerical value
    Sensor = case re:run(Msg, "\"sensor\"\\s*:\\s*\"([^\"]+)\"", [{capture, [1], binary}]) of
        {match, [S]} -> S;
        _ -> <<"telemetry">>
    end,
    case re:run(Msg, "([0-9]+\\.?[0-9]*)", [global, {capture, [1], list}]) of
        {match, Matches} ->
            lists:foreach(fun([NumStr]) ->
                Val = case string:to_float(NumStr) of
                    {F, []} -> F;
                    _ ->
                        case string:to_integer(NumStr) of
                            {I, []} -> float(I);
                            _ -> 0.0
                        end
                end,
                if Val > 0.0 -> record_point(Sensor, Val); true -> ok end
            end, Matches);
        _ ->
            ok
    end.

query_range(SensorBin, WindowSeconds) ->
    NowMs = erlang:system_time(millisecond),
    CutoffMs = NowMs - (WindowSeconds * 1000),
    Sensor = if is_binary(SensorBin) -> SensorBin; is_list(SensorBin) -> list_to_binary(SensorBin); true -> <<"telemetry">> end,
    All = ets:tab2list(?TABLE),
    [ {TimeMs, S, Val} || {{TimeMs, _Id}, S, Val} <- All, TimeMs >= CutoffMs, (Sensor =:= <<"all">> orelse S =:= Sensor) ].

get_aggregates(SensorBin, WindowSeconds) ->
    Points = query_range(SensorBin, WindowSeconds),
    Values = [V || {_, _, V} <- Points],
    Count = length(Values),
    if
        Count > 0 ->
            Min = lists:min(Values),
            Max = lists:max(Values),
            Sum = lists:sum(Values),
            Avg = Sum / Count,
            Variance = lists:sum([ (X - Avg) * (X - Avg) || X <- Values ]) / Count,
            StdDev = math:sqrt(Variance),
            Sorted = lists:sort(Values),
            P95Idx = max(1, round(Count * 0.95)),
            P99Idx = max(1, round(Count * 0.99)),
            P95 = lists:nth(min(P95Idx, Count), Sorted),
            P99 = lists:nth(min(P99Idx, Count), Sorted),
            {Count, Min, Max, Avg, StdDev, P95, P99};
        true ->
            {0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
    end.

get_timeseries_json(WindowSeconds) ->
    Points = query_range(<<"all">>, WindowSeconds),
    Formatted = [ format_point_json(P) || P <- lists:reverse(Points) ],
    list_to_binary("[" ++ string:join(Formatted, ",") ++ "]").

format_point_json({TimeMs, Sensor, Val}) ->
    io_lib:format("{\"time\":~p,\"sensor\":\"~s\",\"value\":~.2f}", [TimeMs, binary_to_list(Sensor), Val]).

get_stats_json() ->
    Points = query_range(<<"all">>, 60),
    Count1m = length(Points),
    RatePerSec = Count1m / 60.0,
    Total = get_total_points(),
    {_, Min, Max, Avg, StdDev, P95, P99} = get_aggregates(<<"all">>, 60),
    io_lib:format("{\"total_recorded\":~p,\"window_60s_count\":~p,\"rate_per_sec\":~.2f,\"min\":~.2f,\"max\":~.2f,\"avg\":~.2f,\"stddev\":~.2f,\"p95\":~.2f,\"p99\":~.2f}",
                  [Total, Count1m, RatePerSec, Min, Max, Avg, StdDev, P95, P99]).

get_total_points() ->
    case ets:info(?TABLE, size) of
        undefined -> 0;
        Size -> Size
    end.
