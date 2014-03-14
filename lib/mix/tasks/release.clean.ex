defmodule Mix.Tasks.Release.Clean do
  @moduledoc """
  Clean up any release-related files.

  ## Examples

    mix release.clean       #=> Cleans release
    mix release.clean --rel #=> Cleans release + generated tools
    mix release.clean --all #=> Cleans absolutely everything

  """
  @shortdoc "Clean up any release-related files."

  use     Mix.Task
  import  ExRM.Release.Utils

  @_RELXCONF "relx.config"
  @_RUNNER   "runner"

  def run(args) do
    debug "Removing release files..."
    cond do
      "--rel" in args ->
        do_cleanup :rel
      "--all" in args ->
        do_cleanup :all
      true ->
        do_cleanup :build
    end
    info "All release files were removed successfully!"
  end

  # Clean release build
  defp do_cleanup(:build) do
    cwd      = File.cwd!
    project  = Mix.project |> Keyword.get(:app) |> atom_to_binary
    release  = cwd |> Path.join("rel") |> Path.join(project)
    if File.exists?(release), do: File.rm_rf!(release)
  end
  # Clean release build + generated tools
  defp do_cleanup(:rel) do
    # Execute build cleanup
    do_cleanup :build

    # Remove generated tools
    clean_relx
    relfiles = File.cwd! |> Path.join("rel")
    if File.exists?(relfiles), do: File.rm_rf!(relfiles)
  end
  defp do_cleanup(:all) do
    # Execute other clean tasks
    do_cleanup :build
    do_cleanup :rel

    # Remove local Elixir
    clean_elixir
  end

end