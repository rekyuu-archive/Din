defmodule Din.Resources.User do
  alias Din.Error

  @moduledoc """
  Users in Discord are generally considered the base entity. Users can spawn across the entire platform, be members of guilds, participate in text and voice chat, and much more. Users are separated by a distinction of "bot" vs "normal." Although they are similar, bot users are automated users that are "owned" by another user. Unlike normal users, bot users do not have a limitation on the number of Guilds they can be a part of.
  """

  @doc """
  Returns the user object of the requester's account. For OAuth2, this requires the `identify` scope, which will return the object without an email, and optionally the `email` scope, which returns the object with an email.
  """
  @spec get_current_user :: map | Error.t
  def get_current_user do
    Din.API.get "/users/@me"
  end

  @doc """
  Returns a user object for a given user ID.
  """
  @spec get(Din.snowflake) :: map | Error.t
  def get(user_id) do
    Din.API.get "/users/#{user_id}"
  end

  @doc """
  Modify the requester's user account settings. Returns a user object on success.
  """
  @spec modify_current_user([
    user: String.t
    avatar: binary
  ]) :: map | Error.t
  def modify_current_user(opts \\ []) do
    Din.API.patch "/users/@me", opts
  end

  @doc """
  Returns a list of partial guild objects the current user is a member of. Requires the `guilds` OAuth2 scope.

  This endpoint returns 100 guilds by default, which is the maximum number of guilds a non-bot user can join. Therefore, pagination is not needed for integrations that need to get a list of users' guilds.
  """
  @spec get_current_user_guilds([
    before: Din.snowflake,
    after: Din.snowflake,
    limit: integer
  ]) :: array(map) | Error.t
  def get_current_user_guilds(opts \\ []) do
    Din.API.get "/users/@me/guilds?#{URI.encode_query opts}"
  end

  @doc """
  Leave a guild. Returns a 204 empty response on success.
  """
  @spec leave_guild(Din.snowflake) :: nil | Error.t
  def leave_guild(guild_id) do
    Din.API.delete "/users/@me/guilds/#{guild_id}"
  end

  @doc """
  Returns a list of DM channel objects.
  """
  @spec get_dms :: list(map) | Error.t
  def get_dms do
    Din.API.get "/users/@me/channels"
  end

  @doc """
  Create a new DM channel with a user. Returns a DM channel object.

  ## Parameters

  - `recipient_id` - the recipient to open a DM channel with
  """
  @spec create_dm([
    recipient_id: Din.snowflake
  ]) :: map | Error.t
  def create_dm(opts \\ []) do
    Din.API.post "/users/@me/channels", opts
  end

  @doc """
  Create a new group DM channel with multiple users. Returns a DM channel object.

  ## Parameters

  - `access_tokens` - access tokens of users that have granted your app the `gdm.join` scope
  - `nicks` - a dictionary of user ids to their respective nicknames
  """
  @spec create_group_dm([
    access_tokens: list(String.t),
    nicks: list(%{Din.snowflake => String.t})
  ]) :: map | Error.t
  def create_group_dm(opts \\ []) do
    Din.API.post "/users/@me/channels", opts
  end

  @doc """
  Returns a list of connection objects. Requires the `connections` OAuth2 scope.
  """
  @spec get_connections :: list(map) | Error.t
  def get_connections do
    Din.API.get "/users/@me/connections"
  end
end
