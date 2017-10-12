defmodule Din.Example do
  use Din.Module

  handle :message_create do
    IO.inspect payload
  end

  handle unused_event, do: IO.inspect unused_event, label: "unused event"
end
