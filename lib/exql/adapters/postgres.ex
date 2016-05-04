defmodule Exql.Adapters.Postgres do

  def query(repo, sql, params) do
    result = Postgrex.query repo, sql, params
  end

  def child_spec(repo, opts) do
    opts = opts
      |> Keyword.put(:types, true)
      |> Keyword.put(:name, repo)
    Postgrex.child_spec opts
  end

end
