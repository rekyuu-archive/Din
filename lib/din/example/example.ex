defmodule Din.Example do
  use Din.Module

  handle :message_create do
    if data.content == "!ping" do
      IO.inspect data
      Din.Resources.Channel.create_message(data.channel_id, "Pong!")
    end

    if data.content == "!react" do
      IO.inspect data
      Din.Resources.Channel.create_reaction(data.channel_id, data.id, "😀")
    end
  end

  handle _event, do: nil
end
