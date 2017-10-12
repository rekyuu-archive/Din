defmodule Din.Resources.AuditLog.Entry do
  alias Din.Resources.Channel

  @typedoc "number of days after which inactive members were kicked"
  @type delete_member_days :: String.t

  @typedoc "number of members removed by the prune"
  @type members_removed :: String.t

  @typedoc "channel in which the messages were deleted"
  @type channel_id :: Channel.id

  @typedoc "number of deleted messages"
  @type count :: String.t

  @typedoc "id of the overwritten entity"
  @type id :: integer

  @typedoc "type of overwritten entity (\"member\" or \"role\")"
  @type type :: String.t

  @typedoc "name of the role if type is \"role\""
  @type role_name :: String.t

  defstruct [:delete_member_days, :members_removed, :channel_id, :count, :id, :type, :role_name]
  @type t :: %__MODULE__{
    delete_member_days: delete_member_days,
    members_removed: members_removed,
    channel_id: channel_id,
    count: count,
    id: id,
    type: type,
    role_name: role_name
  }
end
