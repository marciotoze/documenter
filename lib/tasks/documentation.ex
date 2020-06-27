defmodule Mix.Tasks.Documentation do
  use Mix.Task

  @shortdoc "Prints Ecto help information"

  @moduledoc """
  Prints Ecto tasks and their information.
      mix ecto
  """

  @doc false
  def run(_) do
    Mix.shell().info("A toolkit for data mapping and language integrated query for Elixir.")
    Mix.shell().info("\nAvailable tasks:\n")
    Mix.Tasks.Help.run(["--search", "documentation."])
  end
end
