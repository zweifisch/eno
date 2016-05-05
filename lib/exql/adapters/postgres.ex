defmodule Exql.Adapters.Postgres do

  def query(repo, sql, params) do
    Postgrex.query repo, sql, params
  end

  def child_spec(repo, opts) do
    opts = opts
      |> Keyword.put(:types, true)
      |> Keyword.put(:name, repo)
    Postgrex.child_spec opts
  end

  def run_script(repo, script) do
    {:ok, _} = Application.ensure_all_started(:postgrex)

    {:ok, pid} = Postgrex.start_link repo.config
    sqls = String.split script, ~r/[\r\n]--.*[\r\n]/
    Enum.each sqls, fn sql ->
      result = Postgrex.query pid, sql, []
      case result do
        {:error, error} ->
          Mix.raise "#{error.postgres.message} #{sql}"
        _ -> result
      end
    end
    GenServer.stop pid
  end

end
