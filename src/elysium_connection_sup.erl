%%%-----------------------------------------------------------------------
%%% Elysium_connection_sup restarts worker processes (which each
%%% contain a seestar Cassandra connection and a dictionary of
%%% prepared statements).
%%%-----------------------------------------------------------------------
-module(elysium_connection_sup).
-author('jay@duomark.com').

-behavior(supervisor).

%% External API
-export([start_link/3, init/1]).


%%%-----------------------------------------------------------------------
%%% External API
%%%-----------------------------------------------------------------------
-spec start_link(string(), pos_integer(), pos_integer()) -> {ok, pid()}.
start_link(Ip, Port, Num_Connections)
  when is_list(Ip),
       is_integer(Port), Port > 0,
       is_integer(Num_Connections), Num_Connections > 0 ->

    supervisor:start_link({local, ?MODULE}, ?MODULE,
                          {Ip, Port, Num_Connections}).


%%%-----------------------------------------------------------------------
%%% Internal API
%%%-----------------------------------------------------------------------
-define(CHILD(__Name, __Mod, __Args),
        {__Name, {__Mod, start_link, __Args}, permanent, 2000, worker, [__Mod]}).

-spec init({string(), pos_integer(), pos_integer()})
          -> {ok, {{supervisor:strategy(), non_neg_integer(), non_neg_integer()},
                   [supervisor:child_spec()]}}.
init({Ip, Port, Num_Connections}) ->
    Names    = [list_to_atom("elysium_connection_" ++ integer_to_list(N))
                             || N <- lists:seq(1,Num_Connections)],
    Children = [?CHILD(Name, elysium_connection, [Ip, Port]) || Name <- Names],
    {ok, {{one_for_one, 10, 10}, Children}}.
