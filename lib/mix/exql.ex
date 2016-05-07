defmodule Mix.Exql do

  def get_repos() do
    app = Mix.Project.config[:app]
    Application.get_env(app, :exql_repos) || []
  end

  def get_repo_dir(repo) do
    Path.join [:code.priv_dir(Mix.Project.config[:app]),
               "migrations",
               (repo |> Module.split |> List.last |> Macro.underscore)]
  end

  def get_scripts(ext, repo) do
    case File.ls get_repo_dir repo do
      {:ok, files} -> Enum.filter files, fn file -> String.ends_with? file, ext end
      _ -> Mix.raise "Make sure #{get_repo_dir repo} exists"
    end
  end

  def load_script(path, repo) do
    dir = get_repo_dir repo
    {:ok, content} = File.read Path.join dir, path
    content
  end

  def parse_repos(args) do
    {opts, _, _} = OptionParser.parse args,
      switches: [repo: :string],
      aliases: [r: :repo]

    case opts[:repo] do
      nil -> get_repos()
      name -> [Module.concat String.split(name, ".")]
    end
  end

  def get_migration_history(repo) do
    repo.config[:adapter].migrations_ran repo
  end

  def migrate(repo, version, sql) do
    repo.config[:adapter].migrate repo, version, sql
  end

  def rollback(repo, version, sql) do
    repo.config[:adapter].rollback repo, version, sql
  end

  def parse_version(filename) do
    {version, _} = String.split_at filename, 14
    String.to_integer version
  end

end
