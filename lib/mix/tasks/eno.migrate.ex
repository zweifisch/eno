defmodule Mix.Tasks.Eno.Migrate do
  use Mix.Task
  import Mix.Eno
  import Logger

  @shortdoc "Runs the repository migrations"

  @moduledoc """
  ## Examples

      mix eno.migrate
      mix eno.migrate -r App.Repo

  """

  @doc false
  def run(args) do
    Mix.Task.run "loadpaths"

    repos = parse_repos args

    Enum.each repos, fn repo ->
      scripts = get_scripts(".up.sql", repo) |> Enum.sort
      migrations_ran = MapSet.new get_migration_history repo

      Enum.each scripts, fn script ->
        version = parse_version script
        unless MapSet.member? migrations_ran, version do
          migrate repo, version, load_script(script, repo)
          log :info, "Migrated #{version}"
        end
      end
    end
  end
end
