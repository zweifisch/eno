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

end
