defmodule Din.Resources.Voice do
  alias Din.Error

  @doc """
  Returns an array of voice region objects that can be used when creating servers.
  """
  @spec list_regions :: list(map) | Error.t
  def list_regions do
    Din.API.get "/voice/regions"
  end
end
