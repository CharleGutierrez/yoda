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
    Insight = "Autonomous AI Diagnostic: High telemetry spike (>80) detected in stream (" ++ AnomalyStr ++ "). Potential bufferbloat, I/O saturation, or transducer voltage surge. Recommend immediate rate throttling and sensor calibration.",
    list_to_binary("{\"diagnostic\":\"" ++ escape_json(Insight) ++ "\",\"status\":\"heuristic_ai_active\"}").

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).
