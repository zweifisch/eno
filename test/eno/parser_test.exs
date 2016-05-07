defmodule EnoParserTest do
  use ExUnit.Case
  doctest Eno.Parser

  test "parse" do

    input = """
-- name: user_create!
INSERT INTO users (name, password, roles)
VALUES (:name, :password, :roles::text[])

-- name: user_exists?
select count(0) from users where name = :name;

-- name: user_delete!
delete from users where id = :id


--   name:   user_get


select * from users

where id = :id
"""
    [create, exists, delete, get] = Eno.Parser.parse(input)
    assert create[:name] == :user_create!
    assert exists[:name] == :user_exists?
    assert delete[:name] == :user_delete!
    assert get[:name] == :user_get
    {sql, _} = get[:sql]
    assert sql == "select * from users\nwhere id = $1"
  end
end
