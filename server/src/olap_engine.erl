-module(olap_engine).
-export([init/0, execute_olap/1, insert_row/5, insert_row/6, get_row_count/0]).

-define(COL_DEVICE, yoda_col_device).
-define(COL_TIME, yoda_col_time).
-define(COL_TEMP, yoda_col_temp).
-define(COL_PRESS, yoda_col_press).
-define(COL_REGION, yoda_col_region).

init() ->
    case ets:info(?COL_DEVICE) of
        undefined ->
            ets:new(?COL_DEVICE, [named_table, public, ordered_set]),
            ets:new(?COL_TIME, [named_table, public, ordered_set]),
            ets:new(?COL_TEMP, [named_table, public, ordered_set]),
            ets:new(?COL_PRESS, [named_table, public, ordered_set]),
            ets:new(?COL_REGION, [named_table, public, ordered_set]),
            lists:foreach(fun(I) ->
                Device = list_to_binary("device_" ++ integer_to_list(I rem 10)),
                Time = erlang:system_time(second) - (100 - I) * 60,
                Temp = 30.0 + (I rem 50) * 1.2,
                Press = 90.0 + (I rem 20) * 2.5,
                Region = case I rem 3 of 0 -> <<"us-east">>; 1 -> <<"eu-central">>; _ -> <<"ap-south">> end,
                insert_row(I, Device, Time, Temp, Press, Region)
            end, lists:seq(1, 100));
        _ -> ok
    end,
    ok.

insert_row(RowId, Device, Time, Temp, Press) ->
    insert_row(RowId, Device, Time, Temp, Press, <<"us-east">>).

insert_row(RowId, Device, Time, Temp, Press, Region) ->
    ets:insert(?COL_DEVICE, {RowId, Device}),
    ets:insert(?COL_TIME, {RowId, Time}),
    ets:insert(?COL_TEMP, {RowId, float(Temp)}),
    ets:insert(?COL_PRESS, {RowId, float(Press)}),
    ets:insert(?COL_REGION, {RowId, Region}),
    RowId.

get_row_count() ->
    case ets:info(?COL_DEVICE, size) of
        undefined -> 0;
        Size -> Size
    end.

execute_olap(QueryBin) ->
    db_manager:simulate_db(<<"Snowflake_ClickHouse">>, QueryBin).
