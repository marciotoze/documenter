defmodule Mix.Tasks.Documentation.Run do
  use Mix.Task

  alias Mix.Project

  @shortdoc "Prints Ecto help information"

  @moduledoc """
  Prints Ecto tasks and their information.
      mix ecto xxx
  """

  @doc false
  def run(_) do
    check_requirements()
    build_config_file()
    create_api_doc()
    create_doc()
    release()
  end

  defp release() do
    from = "deps/documenter/.releaserc"
    to = "."

    case System.cmd("cp", [from, to]) do
      {_, 0} -> Mix.Shell.IO.info("Copy Done.")
      {error, _} -> Mix.Shell.IO.error(error)
    end

    semantic_release_bin = "deps/documenter/node_modules/semantic-release/bin/semantic-release.js"
    repo = Project.config()[:source_url]

    params = ["-r", repo]

    case System.cmd("node", [semantic_release_bin | params]) do
      {result, 0} ->
        Mix.Shell.IO.info(result)
        Mix.Shell.IO.info("Release Done.")

      {error, _} ->
        Mix.Shell.IO.error(error)
    end
  end

  defp create_doc(), do: Mix.Tasks.Docs.run([])

  defp create_api_doc do
    input_dir = "#{File.cwd!()}/lib/#{Project.config()[:app]}_web/controllers"
    output_dir = "#{File.cwd!()}/doc/apidoc/"
    template_dir = "deps/documenter/node_modules/dash-apidoc-template/template/"
    apidoc_bin = "deps/documenter/node_modules/apidoc/bin/apidoc"

    params = ["-i", input_dir, "-o", output_dir, "-t", template_dir]

    case System.cmd("node", [apidoc_bin | params]) do
      {_, 0} ->
        Mix.Shell.IO.info("apiDoc successfully generated.")

      {error, _} ->
        Mix.Shell.IO.error(error)
    end
  end

  defp build_config_file do
    file_path = "#{File.cwd!()}/apidoc.json"

    content =
      %{
        name: Project.config()[:name],
        version: Project.config()[:version],
        description: Project.config()[:description],
        title: Project.config()[:name],
        url: Project.config()[:homepage_url]
      }
      |> Jason.encode!()

    File.write(file_path, content)
  end

  defp check_requirements do
    required_configs = ~w(name homepage_url source_url version description)a

    errors =
      Enum.reduce(required_configs, [], fn required, acc ->
        if is_nil(Project.config()[required]) do
          [required | acc]
        else
          acc
        end
      end)

    if Enum.any?(errors) do
      Mix.raise("Please specify [#{Enum.join(errors, ", ")}] config in application on mix.exs")
    end
  end
end
