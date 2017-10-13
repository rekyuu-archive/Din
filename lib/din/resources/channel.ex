defmodule Din.Resources.Channel do
  alias Din.Resources.{Channel, User}
  alias Din.Error

  @typedoc "the id of this channel"
  @type id :: integer

  @typedoc "the type of channel"
  @type type :: 0..4

  @typedoc "the id of the guild"
  @type guild_id :: integer

  @typedoc "sorting position of the channel"
  @type position :: integer

  @typedoc "explicit permission overwrites for members and roles"
  @type permission_overwrites :: list(Channel.Overwrite.t)

  @typedoc "the name of the channel (2-100 characters)"
  @type name :: String.t

  @typedoc "the channel topic (0-1024 characters)"
  @type topic :: String.t

  @typedoc "if the channel is nsfw"
  @type nsfw :: boolean

  @typedoc "the id of the last message sent in this channel (may not point to an existing or valid message)"
  @type last_message_id :: boolean | nil

  @typedoc "the bitrate (in bits) of the voice channel"
  @type bitrate :: integer

  @typedoc "the user limit of the voice channel"
  @type user_limit :: integer

  @typedoc "the recipients of the DM"
  @type recipients :: list(User.t)

  @typedoc "icon hash"
  @type icon :: String.t | nil

  @typedoc "id of the DM creator"
  @type owner_id :: integer

  @typedoc "application id of the group DM creator if it is bot-created"
  @type application_id :: integer

  @typedoc "id of the parent category for a channel"
  @type parent_id :: integer | nil

  @enforce_keys [:id, :type]
  defstruct [:id, :type, :guild_id, :position, :permission_overwrites, :name, :topic, :nsfw, :last_message_id, :bitrate, :user_limit, :recipients, :icon, :owner_id, :application_id, :parent_id]
  @type t :: %__MODULE__{
    id: id,
    type: type,
    guild_id: guild_id,
    position: position,
    permission_overwrites: permission_overwrites,
    name: name,
    topic: topic,
    nsfw: nsfw,
    last_message_id: last_message_id,
    bitrate: bitrate,
    user_limit: user_limit,
    recipients: recipients,
    icon: icon,
    owner_id: owner_id,
    application_id: application_id,
    parent_id: parent_id
  }

  @doc """
  Get a channel by ID. Returns a [channel](t:t/0) object.
  """
  @spec get_channel(id) :: t | Error.t
  def get_channel(channel_id) do
    Din.API.get "/channels/#{channel_id}"
  end

  @doc """
  Update a channels settings. Requires the 'MANAGE_CHANNELS' permission for the guild. Returns a [channel](t:t/0) on success, and a `:error` on invalid parameters. Fires a Channel Update Gateway event. If modifying a category, individual Channel Update events will fire for each child channel that also changes.

  ## Options

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
  @spec modify_channel(id, [
    name: String.t,
    position: integer,
    topic: String.t,
    nsfw: boolean,
    bitrate: integer,
    user_limit: integer,
    permission_overwrites: list(Channel.Overwrite.t),
    parent_id: integer
  ]) :: t | Error.t
  def modify_channel(channel_id, opts) do
    Din.API.patch "/channels/#{channel_id}", opts
  end

  @doc """
  Delete a channel, or close a private message. Requires the 'MANAGE_CHANNELS' permission for the guild. Deleting a category does not delete its child channels; they will have their parent_id removed and a Channel Update Gateway event will fire for each of them. Returns a channel object on success. Fires a Channel Delete Gateway event.

  ## Warning

  Deleting a guild channel cannot be undone. Use this with caution, as it is impossible to undo this action when performed on a guild channel. In contrast, when used with a private message, it is possible to undo the action by opening a private message with the recipient again.
  """
  @spec delete_channel(id) :: t | Error.t
  def delete_channel(channel_id) do
    Din.API.delete "/channels/#{channel_id}"
  end

  @doc """
  Returns the messages for a channel. If operating on a guild channel, this endpoint requires the 'READ_MESSAGES' permission to be present on the current user. Returns an array of [message](t:Channel.Message.t/0) objects on success.

  ## Options

  - `around` - get messages around this message ID
  - `before` - get messages before this message ID
  - `after` - get messages after this message ID
  - `limit` - max number of messages to return (1-100)
  """
  @spec get_channel_messages(id, [
    around: Channel.Message.id,
    before: Channel.Message.id,
    after: Channel.Message.id,
    limit: 1..100
  ]) :: list(Channel.Message.t) | Error.t
  def get_channel_messages(channel_id, opts \\ []) do
    query = URI.encode_query(opts)
    Din.API.get "/channels/#{channel_id}/messages?#{query}"
  end

  @doc """
  Returns a specific message in the channel. If operating on a guild channel, this endpoints requires the 'READ_MESSAGE_HISTORY' permission to be present on the current user. Returns a [message](t:Channel.Message.t/0) object on success.
  """
  @spec get_channel_message(id, Channel.Message.id) :: Channel.Message.t | Error.t
  def get_channel_message(channel_id, message_id) do
    Din.API.get "/channels/#{channel_id}/messages/#{message_id}"
  end

  @doc """
  Post a message to a guild text or DM channel. If operating on a guild channel, this endpoint requires the 'SEND_MESSAGES' permission to be present on the current user. Returns a [message](t:Channel.Message.t/0) object. Fires a Message Create Gateway event.

  ## Options
  - `nonce` - a nonce that can be used for optimistic message sending
  - `tts` - true if this is a TTS message
  - `file` - the contents of the file being sent
  - `embed` - embedded rich content
  """
  @spec create_message(id, String.t, [
    nonce: integer,
    tts: boolean,
    file: binary,
    embed: Channel.Embed.t
  ]) :: Channel.Message.t | Error.t
  def create_message(channel_id, content, opts \\ []) do
    data = Keyword.put(opts, :content, content)
    endpoint = "/channels/#{channel_id}/messages"

    case Keyword.has_key?(data, :file) do
      true -> Din.API.multipart endpoint, data
      false -> Din.API.post endpoint, data
    end
  end
end
