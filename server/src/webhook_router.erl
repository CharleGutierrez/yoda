-module(webhook_router).
-export([dispatch_alert/3]).

dispatch_alert(UrlBin, AlertMsgBin, DiagnosticBin) ->
    inets:start(),
    ssl:start(),
    Url = binary_to_list(UrlBin),
    AlertMsg = binary_to_list(AlertMsgBin),
    Diagnostic = binary_to_list(DiagnosticBin),
    
    Payload = format_payload_for_url(Url, AlertMsg, Diagnostic),
    Request = {Url, [], "application/json", Payload},
    spawn(fun() ->
        httpc:request(post, Request, [{ssl, [{verify, verify_none}]}], [])
    end),
    ok.

format_payload_for_url(Url, AlertMsg, Diagnostic) ->
    case is_discord(Url) of
        true ->
            format_discord(AlertMsg, Diagnostic);
        false ->
            case is_slack(Url) of
                true -> format_slack(AlertMsg, Diagnostic);
                false -> format_generic(AlertMsg, Diagnostic)
            end
    end.

is_discord(Url) ->
    string:str(Url, "discord.com/api/webhooks") > 0.

is_slack(Url) ->
    string:str(Url, "hooks.slack.com") > 0.

format_discord(AlertMsg, Diagnostic) ->
    EscapedMsg = escape_json(AlertMsg),
    EscapedDiag = escape_json(Diagnostic),
    "{\"username\":\"Yoda Telemetry Sentry\",\"avatar_url\":\"https://raw.githubusercontent.com/CharleGutierrez/yoda/main/assets/logo.svg\",\"embeds\":[{\"title\":\"🚨 High-Frequency Telemetry Anomaly Detected\",\"description\":\"" ++ EscapedMsg ++ "\",\"color\":15548997,\"fields\":[{\"name\":\"Autonomous AI Diagnostic\",\"value\":\"" ++ EscapedDiag ++ "\",\"inline\":false}],\"footer\":{\"text\":\"Yoda Real-Time Sentinel • SHA-256 Ledger Verified\"}}]}".

format_slack(AlertMsg, Diagnostic) ->
    EscapedMsg = escape_json(AlertMsg),
    EscapedDiag = escape_json(Diagnostic),
    "{\"blocks\":[{\"type\":\"header\",\"text\":{\"type\":\"plain_text\",\"text\":\"🚨 Yoda Telemetry Alert\"}},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"*Anomaly Detected:* " ++ EscapedMsg ++ "\n*AI Diagnostic:* " ++ EscapedDiag ++ "\"}}]}".

format_generic(AlertMsg, Diagnostic) ->
    EscapedMsg = escape_json(AlertMsg),
    EscapedDiag = escape_json(Diagnostic),
    "{\"alert\":\"Anomaly detected\",\"message\":\"" ++ EscapedMsg ++ "\",\"diagnostic\":\"" ++ EscapedDiag ++ "\",\"timestamp\":" ++ integer_to_list(erlang:system_time(second)) ++ "}".

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).
