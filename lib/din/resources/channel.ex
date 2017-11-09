defmodule Din.Resources.Channel do
  alias Din.Error

  @doc """
  Get a channel by ID.

  Returns a channel object.
  """
  @spec get(Din.snowflake) :: map | Error.t
  def get(channel_id) do
    Din.API.get "/channels/#{channel_id}"
  end

  @doc """
  Update a channels settings.

  Requires the `MANAGE_CHANNELS` permission for the guild. Returns a channel on success, and a `t:Din.Error.t/0` on invalid parameters. Fires a Channel Update Gateway event. If modifying a category, individual Channel Update events will fire for each child channel that also changes.

  ## Parameters

  ### All Channels

  - `name` - 2-100 character channel name
  - `position` - the position of the channel in the left-hand listing
  - `permission_overwrites` - channel or category-specific permissions
  - `parent_id` - id of the new parent category for a channel

  ### Text Channels

  - `topic` - 0-1024 character channel topic
  - `nsfw` - if the channel is nsfw

  ### Voice Channels

  - `bitrate` - the bitrate (in bits) of the voice channel; 8000 to 96000 (128000 for VIP servers)
  - `user_limit` - the user limit of the voice channel; 0 refers to no limit, 1 to 99 refers to a user limit
  """
  @spec modify(Din.snowflake, [
    name: String.t,
    position: integer,
    topic: String.t,
    nsfw: boolean,
    bitrate: integer,
    user_limit: integer,
    permission_overwrites: list(map),
    parent_id: Din.snowflake
  ]) :: map | Error.t
  def modify(channel_id, opts \\ []) do
    Din.API.patch "/channels/#{channel_id}", opts
  end

  @doc """
  Delete a channel, or close a private message.

  Requires the `MANAGE_CHANNELS` permission for the guild. Deleting a category does not delete its child channels; they will have their `parent_id` removed and a Channel Update Gateway event will fire for each of them. Returns a channel object on success. Fires a Channel Delete Gateway event.

  Deleting a guild channel cannot be undone. Use this with caution, as it is impossible to undo this action when performed on a guild channel. In contrast, when used with a private message, it is possible to undo the action by opening a private message with the recipient again.
  """
  @spec delete(Din.snowflake) :: map | Error.t
  def delete(channel_id) do
    Din.API.delete "/channels/#{channel_id}"
  end

  @doc """
  Returns the messages for a channel.

  If operating on a guild channel, this endpoint requires the `READ_MESSAGES` permission to be present on the current user. Returns an array of message objects on success.

  ## Parameters

  - `around` - get messages around this message ID
  - `before` - get messages before this message ID
  - `after` - get messages after this message ID
  - `limit` - max number of messages to return (1-100)
  """
  @spec get_messages(Din.snowflake, [
    around: Din.snowflake,
    before: Din.snowflake,
    after: Din.snowflake,
    limit: 1..100
  ]) :: list(map) | Error.t
  def get_messages(channel_id, opts \\ []) do
    query = URI.encode_query(opts)
    Din.API.get "/channels/#{channel_id}/messages?#{query}"
  end

  @doc """
  Returns a specific message in the channel.

  If operating on a guild channel, this endpoints requires the `READ_MESSAGE_HISTORY` permission to be present on the current user. Returns a message object on success.
  """
  @spec get_message(Din.snowflake, Din.snowflake) :: map | Error.t
  def get_message(channel_id, message_id) do
    Din.API.get "/channels/#{channel_id}/messages/#{message_id}"
  end

  @doc """
  Post a message to a guild text or DM channel.

  If operating on a guild channel, this endpoint requires the `SEND_MESSAGES` permission to be present on the current user. Returns a message object. Fires a Message Create Gateway event.

  ## Parameters

  - `nonce` - a nonce that can be used for optimistic message sending
  - `tts` - true if this is a TTS message
  - `file` - the contents of the file being sent
  - `embed` - embedded rich content
  """
  @spec create_message(Din.snowflake, String.t, [
    nonce: Din.snowflake,
    tts: boolean,
    file: binary,
    embed: map
  ]) :: map | Error.t
  def create_message(channel_id, content, opts \\ []) do
    data = Keyword.put(opts, :content, content)
    endpoint = "/channels/#{channel_id}/messages"
    
    opts = case opts[:file] do
      nil -> opts
      file_binary -> 
        Keyword.update!(opts, :file, &(Base.url_encode64(file_binary)))
    end

    case Keyword.has_key?(data, :file) do
      true -> Din.API.multipart endpoint, data
      false -> Din.API.post endpoint, data
    end
  end

  @doc """
  Create a reaction for the message.

  This endpoint requires the `READ_MESSAGE_HISTORY` permission to be present on the current user. Additionally, if nobody else has reacted to the message using this emoji, this endpoint requires the `ADD_REACTIONS` permission to be present on the current user. Returns `:ok` on success.
  """
  @spec create_reaction(Din.snowflake, Din.snowflake, String.t) :: :ok | Error.t
  def create_reaction(channel_id, message_id, emoji) do
    Din.API.put "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"
  end

  @doc """
  Delete a reaction the current user has made for the message.

  Returns `:ok` on success.
  """
  @spec delete_reaction(Din.snowflake, Din.snowflake, String.t) :: :ok | Error.t
  def delete_reaction(channel_id, message_id, emoji) do
    Din.API.delete "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/@me"
  end

  @doc """
  Deletes another user's reaction.

  This endpoint requires the `MANAGE_MESSAGES` permission to be present on the current user. Returns `:ok` on success.
  """
  @spec delete_user_reaction(Din.snowflake, Din.snowflake, String.t, Din.snowflake) :: :ok | Error.t
  def delete_user_reaction(channel_id, message_id, emoji, user_id) do
    Din.API.delete "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}/#{user_id}"
  end

  @doc """
  Get a list of users that reacted with this emoji.

  Returns an array of user objects on success.
  """
  @spec get_reactions(Din.snowflake, Din.snowflake, String.t) :: list(map) | Error.t
  def get_reactions(channel_id, message_id, emoji) do
    Din.API.get "/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji}"
  end

  @doc """
  Deletes all reactions on a message.

  This endpoint requires the `MANAGE_MESSAGES` permission to be present on the current user.
  """
  @spec delete_all_reactions(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_all_reactions(channel_id, message_id) do
    Din.API.delete "/channels/#{channel_id}/messages/#{message_id}/reactions"
  end

  @doc """
  Edit a previously sent message.

  You can only edit messages that have been sent by the current user. Returns a message object. Fires a Message Update Gateway event.

  ## Parameters

  - `content` - the new message contents (up to 2000 characters)
  - `embed` - embedded rich content
  """
  @spec edit_message(Din.snowflake, Din.snowflake, [
    content: String.t,
    embed: map
  ]) :: map | Error.t
  def edit_message(channel_id, message_id, opts \\ []) do
    Din.API.patch "/channels/#{channel_id}/messages/#{message_id}", opts
  end

  @doc """
  Delete a message.

  If operating on a guild channel and trying to delete a message that was not sent by the current user, this endpoint requires the `MANAGE_MESSAGES` permission. Returns a `:ok` on success. Fires a Message Delete Gateway event.
  """
  @spec delete_message(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_message(channel_id, message_id) do
    Din.API.delete "/channels/#{channel_id}/messages/#{message_id}"
  end

  @doc """
  Delete multiple messages in a single request.

  This endpoint can only be used on guild channels and requires the `MANAGE_MESSAGES` permission. Returns `:ok` on success. Fires multiple Message Delete Gateway events.

  Any message IDs given that do not exist or are invalid will count towards the minimum and maximum message count (currently 2 and 100 respectively). Additionally, duplicated IDs will only be counted once.

  This endpoint will not delete messages older than 2 weeks, and will fail if any message provided is older than that. An endpoint will be added in the future to prune messages older than 2 weeks from a channel.
  """
  @spec bulk_delete_messages(Din.snowflake, list(Din.snowflake)) :: :ok | Error.t
  def bulk_delete_messages(channel_id, message_ids) do
    Din.API.post "/channels/#{channel_id}/messages/bulk-delete", message_ids
  end

  @doc """
  Edit the channel permission overwrites for a user or role in a channel.

  Only usable for guild channels. Requires the `MANAGE_ROLES` permission. Returns `:ok` on success.
  """
  @spec edit_permissions(Din.snowflake, Din.snowflake, [
    allow: integer,
    deny: integer,
    type: String.t
  ]) :: :ok | Error.t
  def edit_permissions(channel_id, overwrite_id, opts) do
    Din.API.put "/channels/#{channel_id}/permissions/#{overwrite_id}", opts
  end

  @doc """
  Returns a list of invite objects (with invite metadata) for the channel.

  Only usable for guild channels. Requires the `MANAGE_CHANNELS` permission.
  """
  @spec get_invites(Din.snowflake) :: list(map) | Error.t
  def get_invites(channel_id) do
    Din.API.get "/channels/#{channel_id}/invites"
  end

  @doc """
  Create a new invite object for the channel.

  Only usable for guild channels. Requires the `CREATE_INSTANT_INVITE` permission.

  ## Parameters

  - `max_age` - Duration of invite in seconds before expiry, or 0 for never. Defaults to `86400` (24 hours.
  - `max_uses` - Max number of uses or 0 for unlimited. Defaults to `0`
  - `temporary` - Whether this invite only grants temporary membership. Defaults to `false`.
  - `unique` - If true, don't try to reuse a similar invite (useful for creating many unique one time use invites). Defaults to `false`.
  """
  @spec create_invite(Din.snowflake, [
    max_age: integer,
    max_uses: integer,
    temporary: boolean,
    unique: boolean
  ]) :: map | Error.t
  def create_invite(channel_id, opts \\ []) do
    Din.API.post "/channels/#{channel_id}/invites", opts
  end

  @doc """
  Delete a channel permission overwrite for a user or role in a channel.

  Only usable for guild channels. Requires the `MANAGE_ROLES` permission. Returns `:ok` on success.
  """
  @spec delete_permission(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_permission(channel_id, overwrite_id) do
    Din.API.delete "/channels/#{channel_id}/permissions/#{overwrite_id}"
  end

  @doc """
  Post a typing indicator for the specified channel.

  Generally bots should not implement this route. However, if a bot is responding to a command and expects the computation to take a few seconds, this endpoint may be called to let the user know that the bot is processing their message. Returns `:ok` on success. Fires a Typing Start Gateway event.
  """
  @spec trigger_typing_indicator(Din.snowflake) :: :ok | Error.t
  def trigger_typing_indicator(channel_id) do
    Din.API.post "/channels/#{channel_id}/typing"
  end

  @doc """
  Returns all pinned messages in the channel as an array of message objects.
  """
  @spec get_pinned_messages(Din.snowflake) :: list(map) | Error.t
  def get_pinned_messages(channel_id) do
    Din.API.get "/channels/#{channel_id}/pins"
  end

  @doc """
  Pin a message in a channel.

  Requires the `MANAGE_MESSAGES` permission. Returns `:ok` on success.
  """
  @spec add_pinned_message(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def add_pinned_message(channel_id, message_id) do
    Din.API.put "/channels/#{channel_id}/pins/#{message_id}"
  end

  @doc """
  Delete a pinned message in a channel.

  Requires the `MANAGE_MESSAGES` permission. Returns `:ok` on success.
  """
  @spec delete_pinned_message(Din.snowflake, Din.snowflake) :: :ok | Error.t
  def delete_pinned_message(channel_id, message_id) do
    Din.API.delete "/channels/#{channel_id}/pins/#{message_id}"
  end

  @doc """
  Adds a recipient to a Group DM using their access token.

  ## Parameters

  - `access_token` - access token of a user that has granted your app the `gdm.join` scope
  - `nick` - nickname of the user being added
  """
  @spec group_dm_add_recipient(Din.snowflake, Din.snowflake, [
    access_token: String.t,
    nick: String.t
  ]) :: map | Error.t
  def group_dm_add_recipient(channel_id, user_id, opts \\ []) do
    Din.API.put "/channels/#{channel_id}/recipients/#{user_id}", opts
  end

  @doc """
  Removes a recipient from a Group DM.
  """
  @spec group_dm_delete_recipient(Din.snowflake, Din.snowflake) :: map | Error.t
  def group_dm_delete_recipient(channel_id, user_id) do
    Din.API.delete "/channels/#{channel_id}/recipients/#{user_id}"
  end
end
