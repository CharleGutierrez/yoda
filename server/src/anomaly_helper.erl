-module(anomaly_helper).
-export([check_anomaly/1]).

check_anomaly(MsgBin) ->
    Msg = binary_to_list(MsgBin),
    case re:run(Msg, "([0-9]+\\.?[0-9]*)", [global, {capture, [1], list}]) of
        {match, Matches} ->
            lists:any(fun([NumStr]) ->
                case string:to_float(NumStr) of
                    {F, []} -> F > 80.0;
                    _ ->
                        case string:to_integer(NumStr) of
                            {I, []} -> I > 80;
                            _ -> false
                        end
                end
            end, Matches);
        nomatch ->
            false
    end.
