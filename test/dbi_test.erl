-module(dbi_test).
-compile([debug_info, export_all]).

-include_lib("eunit/include/eunit.hrl").

dbi_basic_test() ->
    application:set_env(dbi, testdb, [
        {type, sqlite},
        {database, ":memory:"}
    ]),
    ok = dbi:start(),
    {ok,0,[]} = dbi:do_query(
        testdb,
        "CREATE TABLE testing ( id int primary key );"),
    {ok,1,[]} = dbi:do_query(
        testdb,
        "INSERT INTO testing(id) VALUES (1)"),
    {ok,4,[]} = dbi:do_query(
        testdb,
        "INSERT INTO testing(id) VALUES (2),(3),(4),(5)"),
    {ok,5,_} = dbi:do_query(testdb, "SELECT * FROM testing"),
    ok = application:stop(dbi),
    ok.

dbi_args_test() ->
    application:set_env(dbi, testdb, [
        {type, sqlite},
        {database, ":memory:"}
    ]),
    ok = dbi:start(),
    {ok,0,[]} = dbi:do_query(
        testdb,
        "CREATE TABLE testing ( id int primary key, comment varchar(100) );"),
    lists:foreach(fun(I) ->
        {ok,1,[]} = dbi:do_query(
            testdb,
            "INSERT INTO testing(id, comment) VALUES ($1, $2)",
            [I, <<"Data that requires sanitization! ' --">>])
    end, lists:seq(1,10)),
    {ok,10,[{_,_}|_]} = dbi:do_query(testdb, "SELECT * FROM testing"),
    ok = application:stop(dbi),
    ok.
