defmodule Exql.Adapters.Postgres do

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

defimpl Poison.Encoder, for: Postgrex.Timestamp do
  def encode(%{day: day, hour: hour, min: min, month: month, sec: sec,
               usec: _, year: year}, options) do
    :io_lib.format("~.B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [year, month, day, hour, min, sec])
      |> :erlang.iolist_to_binary
      |> Poison.Encoder.BitString.encode(options)
  end
end
