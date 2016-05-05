defmodule Exql do

  defp defquery(name, sql, vars) do
    case vars do
      [] ->
        quote do
          @doc """
          """
          def unquote(name)() do
            @adapter.query __MODULE__, unquote(sql), []
          end
        end
      [{varname, _}] ->
        varname = Macro.var varname, nil
        quote do
          @doc """
          """
          def unquote(name)(unquote varname) do
            @adapter.query __MODULE__, unquote(sql), [unquote varname]
          end
        end
      _ ->
        args = Enum.map vars, fn {name, _}-> Macro.var name, nil end
        kwargs = Enum.map vars, fn {name, _}-> quote do: params[unquote name] end
        quote do
          @doc """
          """
          def unquote(name)(params) when is_list params do
            @adapter.query __MODULE__, unquote(sql), [unquote_splicing kwargs]
          end

          @doc """
          """
          def unquote(name)(unquote_splicing args) do
            @adapter.query __MODULE__, unquote(sql), [unquote_splicing args]
          end
        end
    end
  end

  defp defqueries(input) do
    Enum.map(Exql.Parser.parse(input), fn [name: name, sql: {sql, vars}] ->
      defquery name, sql, vars end)
  end

  def loadqueries(path) do
    with {:ok, content} <- File.read(path) do
      defqueries content
    end
  end

  defmacro defqueries(:path, path) do
    loadqueries path
  end

  defmacro defqueries(app, path) do
    loadqueries Path.join :code.priv_dir(app), path
  end

  defmacro __using__(opts) do
    app = opts[:app]
    sqls = Keyword.get opts, :sqls, ["queries.sql"]
    defs = Enum.map sqls, fn path ->
      loadqueries Path.join :code.priv_dir(app), path
    end
    quote do

      config = Exql.Supervisor.get_config __MODULE__

      @adapter config[:adapter]

      def config do
        Exql.Supervisor.get_config __MODULE__
      end

      def start_link() do
        Exql.Supervisor.start_link(__MODULE__, (unquote app), @adapter)
      end

      unquote_splicing defs
    end
  end
end
