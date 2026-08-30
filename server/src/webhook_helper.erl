-module(webhook_helper).
-export([dispatch/2, dispatch_rich/3]).

dispatch(UrlBin, PayloadBin) ->
    inets:start(),
    ssl:start(),
    Url = binary_to_list(UrlBin),
    Payload = binary_to_list(PayloadBin),
    Request = {Url, [], "application/json", Payload},
    spawn(fun() ->
        httpc:request(post, Request, [{ssl, [{verify, verify_none}]}], [])
    end),
    nil.

dispatch_rich(UrlBin, AlertMsgBin, DiagnosticBin) ->
    inets:start(),
    ssl:start(),
    Url = binary_to_list(UrlBin),
    AlertMsg = binary_to_list(AlertMsgBin),
    Diagnostic = binary_to_list(DiagnosticBin),
    
    Payload = case is_discord(Url) of
        true ->
            "{\"username\":\"Yoda AI\",\"embeds\":[{\"title\":\"🚨 Anomaly Alert\",\"description\":\"" ++ escape_json(AlertMsg) ++ "\",\"color\":15548997,\"fields\":[{\"name\":\"Diagnostic\",\"value\":\"" ++ escape_json(Diagnostic) ++ "\"}]}]}";
        false ->
            case is_slack(Url) of
                true ->
                    "{\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"*🚨 Anomaly Detected:*\n" ++ escape_json(AlertMsg) ++ "\n*Diagnostic:*\n" ++ escape_json(Diagnostic) ++ "\"}}]}";
                false ->
                    "{\"alert\":\"Anomaly detected\",\"message\":\"" ++ escape_json(AlertMsg) ++ "\",\"diagnostic\":\"" ++ escape_json(Diagnostic) ++ "\"}"
            end
    end,
    Request = {Url, [], "application/json", Payload},
    spawn(fun() ->
        httpc:request(post, Request, [{ssl, [{verify, verify_none}]}], [])
    end),
    nil.

is_discord(Url) -> string:str(Url, "discord.com") > 0.
is_slack(Url) -> string:str(Url, "hooks.slack.com") > 0.

escape_json(Str) ->
    lists:flatmap(fun
        ($\") -> "\\\"";
        ($\\) -> "\\\\";
        ($\n) -> "\\n";
        ($\r) -> "\\r";
        ($\t) -> "\\t";
        (C) -> [C]
    end, Str).
