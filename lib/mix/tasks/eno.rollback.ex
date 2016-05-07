defmodule Mix.Tasks.Eno.Rollback do
  use Mix.Task
  import Mix.Eno
  import Logger

  @shortdoc "Rollback the repository migrations"

  @moduledoc """
  ## Examples

      mix eno.rollback
      mix eno.rollback -r App.Repo

  """

  @doc false
  def run(args) do
    Mix.Task.run "loadpaths"

    repos = parse_repos args

    Enum.each repos, fn repo ->
      case get_migration_history repo do
        [version|_] ->
          scripts = get_scripts ".down.sql", repo
          case Enum.find scripts, fn script -> version == parse_version script end do
            nil -> Mix.raise "Can't find rollback script for version #{version}"
            script ->
              rollback repo, version, load_script(script, repo)
              log :info, "Rolledback #{version}"
          end
        _ -> log :info, "All migrations rolledback"
      end
    end
  end
end
