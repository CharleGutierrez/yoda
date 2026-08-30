-module(export_engine).
-export([export_csv/0, export_json/0]).

export_csv() ->
    Points = timeseries_store:query_range(<<"all">>, 3600),
    Header = "Timestamp_Ms,Sensor,Value,ISO_Time\n",
    Rows = [ format_csv_row(P) || P <- Points ],
    list_to_binary(Header ++ string:join(Rows, "\n")).

format_csv_row({TimeMs, Sensor, Val}) ->
    io_lib:format("~p,~s,~.2f,~s", [TimeMs, binary_to_list(Sensor), Val, iso_time(TimeMs div 1000)]).

export_json() ->
    timeseries_store:get_timeseries_json(3600).

iso_time(Sec) ->
    {{Y, M, D}, {H, Min, S}} = calendar:gregorian_seconds_to_datetime(Sec + 62167219200),
    lists:flatten(io_lib:format("~4.4.0w-~2.2.0w-~2.2.0wT~2.2.0w:~2.2.0w:~2.2.0wZ", [Y, M, D, H, Min, S])).
