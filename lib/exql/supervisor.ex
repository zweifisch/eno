defmodule Exql.Supervisor do
  use Supervisor

  def get_config(repo) do
    config = Application.get_env :exql, repo
    config
  end

  def start_link(repo, app, adapter) do
    Supervisor.start_link(__MODULE__, {repo, app, adapter})
  end

  def init({repo, _app, adapter}) do
    config = get_config repo
    children = [adapter.child_spec(repo, config)]
    supervise(children, strategy: :one_for_one)
  end

end
