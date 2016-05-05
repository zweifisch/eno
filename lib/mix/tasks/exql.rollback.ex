defmodule Mix.Tasks.Exql.Rollback do
  use Mix.Task
  import Mix.Exql

  @shortdoc "Rollback the repository migrations"

  @moduledoc """
  ## Examples

      mix exql.rollback
      mix exql.rollback -r App.Repo

  """

  @doc false
  def run(args) do
    Mix.Task.run "loadpaths"

    {opts, _, _} = OptionParser.parse args,
      switches: [repo: :string],
      aliases: [r: :repo]

    repos = case opts[:repo] do
      nil -> get_repos()
      name -> [Module.concat String.split(name, ".")]
    end

    Enum.each repos, fn repo ->
      scripts = get_scripts ".down.sql", repo
      Enum.each scripts, fn script ->
        repo.config[:adapter].run_script repo, load_script(script, repo)
      end
    end
  end
end
