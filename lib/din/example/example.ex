defmodule Din.Example do
  use Din.Module

  @moduledoc false

  handle :message_create do
    match "!ping", do: reply "Pong!"
    match "!test", do: reply "Works!"
    match ["!foo", "!bar"], do: reply "Yep!"
  end

  handle_fallback()
end
