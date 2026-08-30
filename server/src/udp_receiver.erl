-module(udp_receiver).
-behavior(gen_server).

-export([start/1, stop/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {socket, port}).

start(Port) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

stop() ->
    gen_server:call(?MODULE, stop).

init([Port]) ->
    case gen_udp:open(Port, [binary, {active, true}, {reuseaddr, true}]) of
        {ok, Socket} ->
            error_logger:info_msg("Yoda UDP Telemetry Ingestion Receiver active on port ~p~n", [Port]),
            {ok, #state{socket = Socket, port = Port}};
        {error, Reason} ->
            error_logger:warning_msg("Yoda UDP could not bind port ~p: ~p~n", [Port, Reason]),
            {ok, #state{socket = undefined, port = Port}}
    end.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({udp, _Socket, _IP, _InPort, Packet}, State) ->
    Msg = if
        byte_size(Packet) > 0 ->
            case binary:part(Packet, 0, min(8, byte_size(Packet))) of
                <<"DBF_DATA">> -> Packet;
                _ -> <<"Update: ", Packet/binary>>
            end;
        true ->
            <<"Update: empty">>
    end,
    % 1. Log to history file
    file_helper_ffi:append_log(<<"data_history.log">>, Msg),
    % 2. Record to cryptographic audit chain
    crypto_audit:add_block(Msg),
    % 3. Broadcast to all active WebSocket clients in real time
    ws_broadcaster:broadcast(Msg),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{socket = Socket}) ->
    if Socket =/= undefined -> gen_udp:close(Socket); true -> ok end,
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
