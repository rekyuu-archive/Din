defmodule Din.Example do
  use Din.Module

  handle :message_create do
    if data.content == "!ping" do
      Din.Resources.Channel.create_message(data.channel_id, "Pong!")
    end
  end

  handle _event, do: nil
end
