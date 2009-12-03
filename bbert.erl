-module(bbert).
-compile(export_all).

-define(LISTEN_PORT, 11300).
-define(TCP_OPTS, [binary, {packet, 4}, {active, false}, {reuseaddr, true}]).

start() ->
  start(?LISTEN_PORT).

start(Port) ->
  io:format("Starting~n"),
  case gen_tcp:listen(Port, ?TCP_OPTS) of
    {ok, ListeningSocket} ->
      io:format("~p Server started ~p~n", [?MODULE, erlang:localtime()]),
      accept_connection(ListeningSocket);
    Error ->
      io:format("start_server error: ~p~n", [Error])
  end.

accept_connection(ListeningSocket) ->
  case gen_tcp:accept(ListeningSocket) of
    {ok, Socket} ->
      spawn_link(?MODULE, responder_loop, [Socket]),
      accept_connection(ListeningSocket);
    {error, Reason} ->
      io:format("acception_connection error: ~p~n", [Reason])
  end.

responder_loop(Socket) ->
    {ok, BinaryTerm} = gen_tcp:recv(Socket, 0),
    io:format("Received binary term : ~p~n", [BinaryTerm]),
    Term = binary_to_term(BinaryTerm),
    io:format("Got term : ~p~n", [Term]),
    case Term of
        { call, hello_world, calc, Args} ->
            Sum = lists:foldl(fun(Acc, X) -> Acc + X end, 0, Args),
            gen_tcp:send(Socket, term_to_binary({reply, Sum}));
        _Any ->
            ok = gen_tcp:close(Socket)
    end.
