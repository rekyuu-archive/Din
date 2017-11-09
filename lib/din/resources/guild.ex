defmodule Din.Resources.Guild do
  alias Din.Error

  @doc """
  Create a new guild.

  Returns a guild object on success. Fires a Guild Create Gateway event.

  By default this endpoint is limited to 10 active guilds. These limits are raised for whitelisted GameBridge applications.

  Creating channel categories from this endpoint is not supported.

  If roles are specified, the required id field within each role object is an integer placeholder, and will be replaced by the API upon consumption. Its purpose is to allow you to overwrite a role's permissions in a channel when also passing in channels with the channels array.

  ## Parameters

  - `name` - name of the guild (2-100 characters)
  - `region` - `{voice_region.id}` for voice
  - `icon` - base64 128x128 jpeg image for the guild icon
  - `verification_level` - guild verification level
  - `default_message_notifications` - default message notifications setting
  - `roles` - new guild roles
  - `channels` - new guild's channels
  """
  @spec create([
    name: String.t,
    region: String.t,
    icon: binary,
    verification_level: integer,
    default_message_notifications: integer,
    roles: list(map),
    channels: list(map)
  ]) :: map | Error.t
  def create(opts \\ []) do
    opts = case opts[:icon] do
      nil -> opts
      file_binary -> Keyword.put opts, :icon, Base.url_encode64(file_binary)
    end
    
    Din.API.post "/guilds", opts
  end

  @doc """
  Returns the guild object for the given id.
  """
  @spec get(Din.snowflake) :: map | Error.t
  def get(guild_id) do
    Din.API.get "/guilds/#{guild_id}"
  end

  @doc """
  Modify a guild's settings.

  Returns the updated guild object on success. Fires a Guild Update Gateway event.

  ## Parameters

  - `name` - name of the guild (2-100 characters)
  - `region` - `{voice_region.id}` for voice
  - `icon` - base64 128x128 jpeg image for the guild icon
  - `verification_level` - guild verification level
  - `default_message_notifications` - default message notifications setting
  - `afk_channel_id` - id for afk channel
  - `afk_timeout` - afk timeout in seconds
  - `icon` - base64 128x128 jpeg image for the guild icon
  - `owner_id` - user id to transfer guild ownership to (must be owner)
  - `splash` - base64 128x128 jpeg image for the guild splash (VIP only)
  """
  @spec modify(Din.snowflake, [
    name: String.t,
    region: String.t,
    icon: binary,
    verification_level: integer,
    default_message_notifications: integer,
    afk_channel_id: Din.snowflake,
    afk_timeout: integer,
    owner_id: Din.snowflake,
    splash: String.t
  ]) :: map | Error.t
  def modify(guild_id, opts \\ []) do
    opts = case opts[:icon] do
      nil -> opts
      file_binary -> Keyword.put opts, :icon, Base.url_encode64(file_binary)
    end
    
    Din.API.patch "/guilds/#{guild_id}", opts
  end

  @doc """
  Delete a guild permanently.

  User must be owner. Returns `:ok` on success. Fires a Guild Delete Gateway event.
  """
  @spec delete(Din.snowflake) :: :ok | Error.t
  def delete(guild_id) do
    Din.API.delete "/guilds/#{guild_id}"
  end

  @doc """
  Returns a list of guild channel objects.
  """
  @spec get_channels(Din.snowflake) :: list(map) | Error.t
  def get_channels(guild_id) do
    Din.API.get "/guilds/#{guild_id}/channels"
  end

  @doc """
  Create a new channel object for the guild.

  Requires the `MANAGE_CHANNELS` permission. Returns the new channel object on success. Fires a Channel Create Gateway event.
  """
  @spec create_channel(Din.snowflake, String.t, [
    type: integer,
    bitrate: integer,
    user_limit: integer,
    permission_overwrites: list(map),
    parent_id: Din.snowflake,
    nsfw: boolean
  ]) :: map | Error.t
  def create_channel(guild_id, channel_name, opts \\ []) do
    data = Keyword.put(opts, :name, channel_name)
    Din.API.post "/guilds/#{guild_id}/channels", data
  end

  @doc """
  Modify the positions of a set of channel objects for the guild.

  Requires `MANAGE_CHANNELS` permission. Returns `:ok` on success. Fires multiple Channel Update Gateway events.

  Only channels to be modified are required, with the minimum being a swap between at least two channels.

  ## Parameters

  - `id` - channel id
  - `position` - sorting position of the channel
  """
  @spec modify_channel_positions(Din.snowflake, list([
    id: Din.snowflake,
    position: integer
  ])) :: :ok | Error.t
  def modify_channel_positions(guild_id, channel_list) do
    Din.API.patch "/guilds/#{guild_id}/channels", channel_list
  end

  @doc """
  Returns a guild member object for the specified user.
  """
  @spec get_member(Din.snowflake, Din.snowflake) :: map | Error.t
  def get_member(guild_id, user_id) do
    Din.API.get "/guilds/#{guild_id}/members/#{user_id}"
  end

  @doc """
  Returns a list of guild member objects that are members of the guild.

  ## Parameters

  - `limit` - max number of members to return (1-1000)
  - `after` - the highest user id in the previous page
  """
  @spec list_members(Din.snowflake, [
    limit: integer,
    after: Din.snowflake
  ]) :: list(map) | Error.t
  def list_members(guild_id, opts \\ []) do
    Din.API.get "/guilds/#{guild_id}/members?#{URI.encode_query opts}"
  end

  @doc """
  Adds a user to the guild.

  You must have a valid oauth2 access token for the user with the `guilds.join` scope. Returns the guild member as the body. Fires a Guild Member Add Gateway event. Requires the bot to have the `CREATE_INSTANT_INVITE` permission.

  ## Parameters

  - `access_token` - an oauth2 access token granted with the guilds.join to the bot's application for the user you want to add to the guild
  - `nick` - value to set users nickname to
  - `roles` - array of role ids the member is assigned
  - `mute` - if the user is muted
  - `deaf` - if the user is deafened
  """
  @spec add_member(Din.snowflake, Din.snowflake, String.t, [
    nick: String.t,
    roles: list(Din.snowflake),
    mute: boolean,
    deaf: boolean
  ]) :: map | Error.t
  def add_member(guild_id, user_id, access_token, opts \\ []) do
    data = Keyword.put(opts, :access_token, access_token)
    Din.API.put "/guilds/#{guild_id}/members/#{user_id}", data
  end

  @doc """
  Modify attributes of a guild member.

  Returns `:ok` on success. Fires a Guild Member Update Gateway event.

  When moving members to channels, the API user must have permissions to both connect to the channel and have the `MOVE_MEMBERS` permission.

  ## Parameters

  - `nick` - value to set users nickname to
  - `roles` - array of role ids the member is assigned
  - `mute` - if the user is muted
  - `deaf` - if the user is deafened
  - `channel_id` - id of channel to move user to (if they are connected to voice)
  """
  @spec modify_member(Din.snowflake, Din.snowflake, [
    nick: String.t,
    roles: list(Din.snowflake),
    mute: boolean,
    deaf: boolean,
    channel_id: Din.snowflake
  ]) :: :ok | Error.t
  def modify_member(guild_id, user_id, opts \\ []) do
    Din.API.patch "/guilds/#{guild_id}/members/#{user_id}", opts
  end

  @doc """
  Modifies the nickname of the current user in a guild.

  Returns the nickname on success. Fires a Guild Member Update Gateway event.
  """
  @spec modify_current_users_nick(Din.snowflake, String.t) :: map | Error.t
  def modify_current_users_nick(guild_id, nickname) do
    Din.API.patch "/guilds/#{guild_id}/members/@me/nick", [nick: nickname]
  end

  @doc """
  Adds a role to a guild member.

  Requires the `MANAGE_ROLES` permission. Returns `:ok` on success. Fires a Guild Member Update Gateway event.
  """
  @spec add_member_role(Din.snowflake, Din.snowflake, Din.snowflake) :: :ok | Error.t
  def add_member_role(guild_id, user_id, role_id) do
    Din.API.put "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"
  end

  @doc """
  Removes a role from a guild member.

  Requires the `MANAGE_ROLES` permission. Returns `:ok` on success. Fires a Guild Member Update Gateway event.
  """
  @spec remove_member_role(Din.snowflake, Din.snowflake, Din.snowflake) :: :ok | Error.t
  def remove_member_role(guild_id, user_id, role_id) do
    Din.API.delete "/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"
  end

  @doc """
  Remove a member from a guild.

  Requires `KICK_MEMBERS` permission. Returns `:ok` on success. Fires a Guild Member Remove Gateway event.
  """
  @spec remove_member(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def remove_member(guild_id, user_id) do
    Din.API.delete "/guilds/#{guild_id}/members/#{user_id}"
  end

  @doc """
  Returns a list of ban objects for the users banned from this guild.

  Requires the `BAN_MEMBERS` permission.
  """
  @spec get_bans(Din.snowflake) :: list(map) | Error.t
  def get_bans(guild_id) do
    Din.API.get "/guilds/#{guild_id}/bans"
  end

  @doc """
  Create a guild ban.

  Optionally delete previous messages sent by the banned user. Requires the `BAN_MEMBERS` permission. Returns `:ok` on success. Fires a Guild Ban Add Gateway event.
  """
  @spec create_ban(Din.snowflake, Din.snowflake, [
    "delete-message_days": integer
  ]) :: :ok | Error.t
  def create_ban(guild_id, user_id, opts \\ []) do
    Din.API.put "/guilds/#{guild_id}/bans/#{user_id}", opts
  end

  @doc """
  Remove the ban for a user.

  Requires the `BAN_MEMBERS` permissions. Returns `:ok` on success. Fires a Guild Ban Remove Gateway event.
  """
  @spec remove_ban(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def remove_ban(guild_id, user_id) do
    Din.API.delete "/guilds/#{guild_id}/bans/#{user_id}"
  end

  @doc """
  Returns a list of role objects for the guild.

  Requires the `MANAGE_ROLES` permission.
  """
  @spec get_roles(Din.snowflake) :: list(map) | Error.t
  def get_roles(guild_id) do
    Din.API.get "/guilds/#{guild_id}/roles"
  end

  @doc """
  Create a new role for the guild.

  Requires the `MANAGE_ROLES` permission. Returns the new role object on success. Fires a Guild Role Create Gateway event.

  ## Parameters

  - `name` - name of the role
  - `permissions` - bitwise of the enabled/disabled permissions
  - `color` - RGB color value
  - `hoist` - whether the role should be displayed separately in the sidebar
  - `mentionable` - whether the role should be mentionable
  """
  @spec create_role(Din.snowflake, [
    name: String.t,
    permissions: integer,
    color: integer,
    hoist: boolean,
    mentionable: boolean
  ]) :: map | Error.t
  def create_role(guild_id, opts \\ []) do
    Din.API.post "/guilds/#{guild_id}/roles", opts
  end

  @doc """
  Modify the positions of a set of role objects for the guild.

  Requires the `MANAGE_ROLES` permission. Returns a list of all of the guild's role objects on success. Fires multiple Guild Role Update Gateway events.
  """
  @spec modify_role_positions(Din.snowflake, list([
    id: Din.snowflake,
    position: integer
  ])) :: list(map) | Error.t
  def modify_role_positions(guild_id, roles_list) do
    Din.API.patch "/guilds/#{guild_id}/roles", roles_list
  end

  @doc """
  Modify a guild role.

  Requires the `MANAGE_ROLES` permission. Returns the updated role on success. Fires a Guild Role Update Gateway event.
  """
  @spec modify_role(Din.snowflake, Din.snowflake, [
    name: String.t,
    permissions: integer,
    color: integer,
    hoist: boolean,
    mentionable: boolean
  ]) :: map | Error.t
  def modify_role(guild_id, role_id, opts \\ []) do
    Din.API.patch "/guilds/#{guild_id}/roles/#{role_id}", opts
  end

  @doc """
  Delete a guild role.

  Requires the `MANAGE_ROLES` permission. Returns `:ok` on success. Fires a Guild Role Delete Gateway event.
  """
  @spec delete_role(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_role(guild_id, role_id) do
    Din.API.delete "/guilds/#{guild_id}/roles/#{role_id}"
  end

  @doc """
  Returns an object with one `pruned` key indicating the number of members that would be removed in a prune operation.

  Requires the `KICK_MEMBERS` permission.

  ## Parameters

  - `days` - number of days to count prune for (1 or more)
  """
  @spec get_prune_count(Din.snowflake, [
    days: integer
  ]) :: map | Error.t
  def get_prune_count(guild_id, opts \\ []) do
    Din.API.get "/guilds/#{guild_id}/prune?#{URI.encode_query opts}"
  end

  @doc """
  Begin a prune operation.

  Requires the `KICK_MEMBERS` permission. Returns an object with one `pruned` key indicating the number of members that were removed in the prune operation. Fires multiple Guild Member Remove Gateway events.

  ## Parameters

  - `days` - number of days to count prune for (1 or more)
  """
  @spec begin_prune(Din.snowflake, [
    days: integer
  ]) :: map | Error.t
  def begin_prune(guild_id, opts \\ []) do
    Din.API.post "/guilds/#{guild_id}/prune?#{URI.encode_query opts}"
  end

  @doc """
  Returns a list of voice region objects for the guild.

  Unlike the similar `Din.Resources.Voice.list_regions/0`, this returns VIP servers when the guild is VIP-enabled.
  """
  @spec get_voice_regions(Din.snowflake) :: list(map) | Error.t
  def get_voice_regions(guild_id) do
    Din.API.get "/guilds/#{guild_id}/regions"
  end

  @doc """
  Returns a list of invite objects (with invite metadata) for the guild.

  Requires the `MANAGE_GUILD` permission.
  """
  @spec get_invites(Din.snowflake) :: list(map) | Error.t
  def get_invites(guild_id) do
    Din.API.get "/guilds/#{guild_id}/invites"
  end

  @doc """
  Returns a list of integration objects for the guild.

  Requires the `MANAGE_GUILD` permission.
  """
  @spec get_integrations(Din.snowflake) :: list(map) | Error.t
  def get_integrations(guild_id) do
    Din.API.get "/guilds/#{guild_id}/integrations"
  end

  @doc """
  Attach an integration object from the current user to the guild.

  Requires the `MANAGE_GUILD` permission. Returns `:ok` on success. Fires a Guild Integrations Update Gateway event.
  """
  @spec create_integration(Din.snowflake, [
    type: String.t,
    id: Din.snowflake
  ]) :: :ok | Error.t
  def create_integration(guild_id, opts \\ []) do
    Din.API.post "/guilds/#{guild_id}/integrations", opts
  end

  @doc """
  Modify the behavior and settings of a integration object for the guild.

  Requires the `MANAGE_GUILD` permission. Returns `:ok` on success. Fires a Guild Integrations Update Gateway event.

  ## Parameters

  - `expire_behavior` - the behavior when an integration subscription lapses (see the integration object documentation)
  - `expire_grace_period` - period (in seconds) where the integration will ignore lapsed subscriptions
  - `enable_emoticons` - whether emoticons should be synced for this integration (twitch only currently)
  """
  @spec modify_integration(Din.snowflake, Din.snowflake, [
    expire_behavior: integer,
    expire_grace_period: integer,
    enable_emoticons: boolean
  ]) :: :ok | Error.t
  def modify_integration(guild_id, integration_id, opts \\ []) do
    Din.API.patch "/guilds/#{guild_id}/integrations/#{integration_id}", opts
  end

  @doc """
  Delete the attached integration object for the guild.

  Requires the `MANAGE_GUILD` permission. Returns `:ok` on success. Fires a Guild Integrations Update Gateway event.
  """
  @spec delete_integration(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_integration(guild_id, integration_id) do
    Din.API.delete "/guilds/#{guild_id}/integrations/#{integration_id}"
  end

  @doc """
  Sync an integration.

  Requires the `MANAGE_GUILD` permission. Returns `:ok` on success.
  """
  @spec sync_integration(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def sync_integration(guild_id, integration_id) do
    Din.API.post "/guilds/#{guild_id}/integrations/#{integration_id}/sync"
  end

  @doc """
  Returns the guild embed object.

  Requires the `MANAGE_GUILD` permission.
  """
  @spec get_embed(Din.snowflake) :: map | Error.t
  def get_embed(guild_id) do
    Din.API.get "/guilds/#{guild_id}/embed"
  end

  @doc """
  Modify a guild embed object for the guild.

  Requires the `MANAGE_GUILD` permission. Returns the updated guild embed object.

  ## Parameters

  - `enabled` - if the embed is enabled
  - `channel_id` - the embed channel id
  """
  @spec modify_embed(Din.snowflake, [
    enabled: boolean,
    channel_id: Din.snowflake
  ]) :: map | Error.t
  def modify_embed(guild_id, opts \\ []) do
    Din.API.patch "/guilds/#{guild_id}/embed", opts
  end
end
