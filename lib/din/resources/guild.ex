defmodule Din.Resources.Guild do
  alias Din.Error

  @moduledoc """
  Guilds in Discord represent an isolated collection of users and channels, and are often referred to as "servers" in the UI.
  """

  @doc """
  Create a new guild. Returns a guild object on success. Fires a Guild Create Gateway event.

  By default this endpoint is limited to 10 active guilds. These limits are raised for whitelisted GameBridge applications.

  Creating channel categories from this endpoint is not supported.

  If roles are specified, the required id field within each role object is an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to overwrite a role's permissions in a channel when also passing in channels with the channels array.

  ## Parameters

  - `name` - name of the guild (2-100 characters)
  - `region` - `{voice_region.id} for voice`
  - `icon` - base64 128x128 jpeg image for the guild icon
  - `verification_level` - guild verification level
  - `default_message_notifications` - default message notifications setting
  - `roles` - new guild roles
  - `channels` - new guild's channels
  """
  @spec create_guild([
    name: String.t,
    region: String.t,
    icon: binary,
    verification_level: integer,
    default_message_notifications: integer,
    roles: list(map),
    channels: list(map)
  ]) :: map | Error.t
  def create_guild(opts \\ []) do
    Din.API.post "/guilds", opts
  end

  @doc """
  Returns the guild object for the given id.
  """
  @spec get_guild(Din.snowflake) :: map | Error.t
  def get_guild(guild_id) do
    Din.API.get "/guilds/#{guild_id}"
  end
end
