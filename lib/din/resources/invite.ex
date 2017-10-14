defmodule Din.Resources.Invite do
  alias Din.Error

  @doc """
  Returns an invite object for the given code.
  """
  @spec get(String.t) :: map | Error.t
  def get(invite_code) do
    Din.API.get "/invites/#{invite_code}"
  end

  @doc """
  Delete an invite. Requires the MANAGE_CHANNELS permission. Returns an invite object on success.
  """
  @spec delete(String.t) :: map | Error.t
  def delete(invite_code) do
    Din.API.delete "/invites/#{invite_code}"
  end

  @doc """
  Accept an invite. This requires the `guilds.join` OAuth2 scope to be able to accept invites on behalf of normal users (via an OAuth2 Bearer token). Bot users are disallowed. Returns an invite object on success.
  """
  @spec accept(String.t) :: map | Error.t
  def accept(invite_code) do
    Din.API.post "/invites/#{invite_code}"
  end
end
