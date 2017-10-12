defmodule Din.Example do
  use Din.Module

  handle :message_create do
    if data.content == "!ping" do
      nil
    end
  end

  handle _event, do: nil
end
