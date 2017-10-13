defmodule Din.Resources.Channel do
  alias Din.Resources.{Channel, User}

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
  @spec get_channel(id) :: t
  def get_channel(channel_id) do
    Din.API.get "/channels/#{channel_id}"
  end

  @doc """
  Update a channels settings. Requires the 'MANAGE_CHANNELS' permission for the guild. Returns a [channel](t:t/0) on success, and a `:error` on invalid parameters. Fires a Channel Update Gateway event. If modifying a category, individual Channel Update events will fire for each child channel that also changes.
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
  ]) :: :error | t
  def modify_channel(channel_id, opts) do
    response = Din.API.patch "/channels/#{channel_id}", opts
  end
end
