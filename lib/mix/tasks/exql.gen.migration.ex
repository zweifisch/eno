defmodule Mix.Tasks.Exql.Gen.Migration do
  use Mix.Task

  import Mix.Generator
  import Mix.Exql

  @shortdoc "Generate a new migration for the repo"

  @moduledoc """
  Generates a migration.

  ## Examples

      mix exql.gen.migration add_posts_table
      mix exql.gen.migration add_posts_table -r App.Repo

  """

  @doc false
  def run(args) do
    Mix.Task.run "loadpaths"

    repos = parse_repos args

    Enum.each repos, fn repo ->
      case OptionParser.parse(args, switches: [name: :string]) do
        {_opts, [name], _} ->
          path = get_repo_dir repo
          create_directory path
          script_name = "#{timestamp}_#{Macro.underscore(name)}"
          Enum.each ["up", "down"], fn action ->
            Path.join(path, "#{script_name}.#{action}.sql") |> create_file("")
          end
        {_, _, _} ->
          Mix.raise "Name not specified"
      end
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)

end
