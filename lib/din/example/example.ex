defmodule Din.Example do
  use Din.Module

  handle :message_create do
    IO.inspect payload
  end

  handle unused_event, do: nil
end
