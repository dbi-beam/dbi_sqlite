defmodule SkirnirImapParserTest do
  use ExUnit.Case

  test "basic" do
    assert :ok == DBI.start()
    assert {:ok, 0, []} == DBI.do_query(:testdb1,
                                        "CREATE TABLE testing ( id int primary key );")
    assert {:ok, 1, []} == DBI.do_query(:testdb1,
                                        "INSERT INTO testing(id) VALUES (1)")
    assert {:ok, 4, []} == DBI.do_query(:testdb1,
                                        "INSERT INTO testing(id) VALUES (2),(3),(4),(5)")
    {:ok, 5, _} = DBI.do_query(:testdb1, "SELECT * FROM testing")
    :ok = Application.stop(:dbi)
  end

  test "args" do
    assert :ok == DBI.start()
    assert {:ok, 0, []} = DBI.do_query(:testdb1,
                                       "CREATE TABLE testing ( id int primary key, comment varchar(100) );")
    Enum.each(1..10, fn(i) ->
        assert {:ok, 1, []} == DBI.do_query(:testdb1,
                                           "INSERT INTO testing(id, comment) VALUES ($1, $2)",
                                           [i, "Data that requires sanitization! ' --"])
    end)
    {:ok, 10, [{_,_}|_]} = DBI.do_query(:testdb1, "SELECT * FROM testing")
    :ok = Application.stop(:dbi)
  end
end
