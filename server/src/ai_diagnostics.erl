-module(ai_diagnostics).
-export([diagnose_anomaly/2]).

diagnose_anomaly(AnomalyTextBin, ApiKeyBin) ->
    AnomalyText = if is_binary(AnomalyTextBin) -> binary_to_list(AnomalyTextBin); is_list(AnomalyTextBin) -> AnomalyTextBin; true -> "" end,
    ApiKey = if is_binary(ApiKeyBin) -> binary_to_list(ApiKeyBin); is_list(ApiKeyBin) -> ApiKeyBin; true -> "" end,
    case ApiKey of
        "sk-" ++ _ ->
            Prompt = "Act as an expert industrial reliability engineer. Analyze this anomalous telemetry event: '" ++ AnomalyText ++ "'. Give a 1-sentence root-cause hypothesis and recommended mitigation.",
            Body = "{\"model\":\"gpt-3.5-turbo\",\"messages\":[{\"role\":\"user\",\"content\":\"" ++ escape_json(Prompt) ++ "\"}],\"max_tokens\":100}",
            Url = "https://api.openai.com/v1/chat/completions",
            case curl_wrapper:curl_post(list_to_binary(Url), ApiKeyBin, list_to_binary(Body)) of
                Resp when is_binary(Resp) -> Resp;
                _ -> local_heuristic_diagnostic(list_to_binary(AnomalyText))
            end;
        _ ->
            local_heuristic_diagnostic(list_to_binary(AnomalyText))
    end.

local_heuristic_diagnostic(AnomalyTextBin) ->
    AnomalyStr = binary_to_list(AnomalyTextBin),
    case re:run(AnomalyStr, "([0-9]+\\.?[0-9]*)", [global, {capture, [1], list}]) of
        {match, Matches} ->
            Values = lists:filtermap(fun([NumStr]) ->
                case string:to_float(NumStr) of
                    {F, []} -> {true, F};
                    _ ->
                        case string:to_integer(NumStr) of
                            {I, []} -> {true, float(I)};
                            _ -> false
                        end
                end
            end, Matches),
            case Values of
                [] ->
                    list_to_binary("{\"diagnostic\":\"" ++ escape_json("Anomaly detected, but no metric values found.") ++ "\",\"status\":\"heuristic_ai_active\"}");
                _ ->
                    MaxVal = lists:max(Values),
                    Insight = if
                        MaxVal > 95.0 -> "Critical Failure Warning! Metric exceeded 95.0 limit (" ++ lists:flatten(io_lib:format("~.2f", [MaxVal])) ++ "). Recommend immediate shutdown and physical inspection.";
                        MaxVal > 90.0 -> "Severe Anomaly: Metric spike (" ++ lists:flatten(io_lib:format("~.2f", [MaxVal])) ++ "). Recommend reducing load to prevent transducer damage.";
                        true -> "Elevated Telemetry (" ++ lists:flatten(io_lib:format("~.2f", [MaxVal])) ++ "). Potential bufferbloat or minor voltage surge. Monitor closely."
                    end,
                    list_to_binary("{\"diagnostic\":\"" ++ escape_json(lists:flatten(Insight)) ++ "\",\"status\":\"heuristic_ai_active\"}")
            end;
        nomatch ->
            list_to_binary("{\"diagnostic\":\"" ++ escape_json("Unknown anomaly format.") ++ "\",\"status\":\"heuristic_ai_active\"}")
    end.

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).
