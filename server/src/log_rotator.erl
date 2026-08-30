-module(log_rotator).
-behavior(gen_server).

-export([start/0, rotate/0]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(INTERVAL, 60000).
-define(THRESHOLD, 512000).

start() ->
    start_link(),
    nil.

rotate() ->
    gen_server:call(?MODULE, rotate),
    nil.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    timer:send_interval(?INTERVAL, check_size),
    {ok, []}.

handle_call(rotate, _From, State) ->
    do_rotate(),
    {reply, ok, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(check_size, State) ->
    case file:read_file_info("data_history.log") of
        {ok, FileInfo} ->
            Size = element(2, FileInfo),
            if
                Size > ?THRESHOLD ->
                    do_rotate();
                true ->
                    ok
            end;
        _ ->
            ok
    end,
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

do_rotate() ->
    Time = integer_to_list(erlang:system_time(second)),
    NewName = "data_history.archive." ++ Time ++ ".log",
    file:rename("data_history.log", NewName).
