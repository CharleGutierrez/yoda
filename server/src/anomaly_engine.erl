-module(anomaly_engine).
-export([evaluate_telemetry/1, get_forecast_json/0, calculate_zscore/2]).

evaluate_telemetry(Value) when is_number(Value) ->
    FloatVal = float(Value),
    {Count, _Min, _Max, Avg, StdDev, _P95, _P99} = timeseries_store:get_aggregates(<<"all">>, 60),
    {ZScore, IsStatAnomaly} = if
        Count >= 5, StdDev > 0.001 ->
            Z = (FloatVal - Avg) / StdDev,
            {Z, abs(Z) > 3.0};
        true ->
            {0.0, false}
    end,
    IsThresholdAnomaly = FloatVal > 80.0,
    IsAnomaly = IsStatAnomaly orelse IsThresholdAnomaly,
    {IsAnomaly, ZScore, Avg, StdDev};
evaluate_telemetry(_) ->
    {false, 0.0, 0.0, 0.0}.

calculate_zscore(Value, WindowSeconds) ->
    {_Count, _Min, _Max, Avg, StdDev, _P95, _P99} = timeseries_store:get_aggregates(<<"all">>, WindowSeconds),
    if
        StdDev > 0.001 -> (float(Value) - Avg) / StdDev;
        true -> 0.0
    end.

get_forecast_json() ->
    Points = timeseries_store:query_range(<<"all">>, 30),
    Values = [V || {_, _, V} <- Points],
    Count = length(Values),
    if
        Count >= 3 ->
            % Linear regression slope estimation (y = mx + c)
            N = float(Count),
            Indices = lists:seq(1, Count),
            SumX = lists:sum(Indices),
            SumY = lists:sum(Values),
            SumXY = lists:sum([ float(I) * V || {I, V} <- lists:zip(Indices, Values) ]),
            SumX2 = lists:sum([ float(I * I) || I <- Indices ]),
            Denominator = (N * SumX2) - (SumX * SumX),
            Slope = if
                abs(Denominator) > 0.0001 -> ((N * SumXY) - (SumX * SumY)) / Denominator;
                true -> 0.0
            end,
            LastVal = lists:last(Values),
            Forecast5s = max(0.0, LastVal + (Slope * 5.0)),
            Forecast30s = max(0.0, LastVal + (Slope * 30.0)),
            Trend = if Slope > 0.5 -> "rapid_climb"; Slope > 0.05 -> "climbing"; Slope < -0.5 -> "rapid_drop"; Slope < -0.05 -> "dropping"; true -> "stable" end,
            io_lib:format("{\"current_value\":~.2f,\"slope_rate\":~.4f,\"trend\":\"~s\",\"forecast_5s\":~.2f,\"forecast_30s\":~.2f,\"confidence\":0.95}",
                          [LastVal, Slope, Trend, Forecast5s, Forecast30s]);
        true ->
            "{\"current_value\":0.0,\"slope_rate\":0.0,\"trend\":\"insufficient_data\",\"forecast_5s\":0.0,\"forecast_30s\":0.0,\"confidence\":0.0}"
    end.
