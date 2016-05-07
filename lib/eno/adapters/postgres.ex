defmodule Eno.Adapters.Postgres do

  def query(repo, sql, params) do
    case Postgrex.query repo, sql, params do
      {:ok, %{rows: rows, columns: columns}} ->
        Enum.map rows, fn (row)-> Enum.zip(columns, row) |> Enum.into(%{}) end
      result -> result
    end
  end

  def child_spec(repo, opts) do
    opts = opts
      |> Keyword.put(:types, true)
      |> Keyword.put(:name, repo)
    Postgrex.child_spec opts
  end

  defp run_query(repo, sql, params \\ []) do
    {:ok, _} = Application.ensure_all_started(:postgrex)

    {:ok, pid} = Postgrex.start_link repo.config
    result = Postgrex.query pid, sql, params
    case result do
      {:error, error} ->
        Mix.raise "#{error.postgres.message} #{sql}"
      _ -> result
    end
    GenServer.stop pid
    result
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

  def init_migration(repo) do
    run_query repo, """
CREATE TABLE IF NOT EXISTS eno_migrations (
 version bigint PRIMARY KEY,
 ran_at timestamp NOT NULL DEFAULT (now() at time zone 'utc'));
"""
  end

  def migrations_ran(repo) do
    init_migration repo
    result = run_query repo, """
SELECT version FROM eno_migrations ORDER BY version DESC;
    """
    case result do
      {:ok, %{rows: rows}} -> Enum.map rows, &List.first(&1)
      _ -> result
    end
  end

  def migrate(repo, version, sql) do
    run_script repo, sql
    run_query repo, "INSERT INTO eno_migrations (version) values ($1);", [version]
  end

  def rollback(repo, version, sql) do
    run_script repo, sql
    run_query repo, "DELETE FROM eno_migrations WHERE version = $1;", [version]
  end
end
