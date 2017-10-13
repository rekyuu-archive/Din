defmodule Din.Resources.Channel.Reaction do
  alias Din.Resources.Emoji

  @typedoc "times this emoji has been used to react"
  @type count :: integer

  @typedoc "whether the current user reacted using this emoji"
  @type me :: boolean

  @typedoc "emoji information"
  @type emoji :: Emoji.t

  @enforce_keys [:count, :me, :emoji]
  defstruct [:count, :me, :emoji]
  @type t :: %__MODULE__{
    count: count,
    me: me,
    emoji: emoji
  }
end
