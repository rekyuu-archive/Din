# Din

Din is a Discord wrapper for Elixir.

[Documentation](https://rekyuu.github.io/Din).

It’s focused around simplicity and makes sure to actually reconnect when a connection or heartbeat drops.

## Installation

The package can be installed by adding `din` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:din, git: "https://github.com/rekyuu/Din"}]
end
```

Then start `din` in your applications:

```elixir
def application do
  [applications: [:logger, :din]]
end
```

## Usage

Usage is simple. Include Din in your dependencies and start it from your supervisor ([example](https://github.com/rekyuu/Din/tree/master/lib/din/example)).

```elixir
defmodule YourApplication.YourModule do
  use Din.Module
  alias Din.Resources.Channel

  handle :message_create do
    match "!ping", do: reply "Pong!"
  end

  # Fallback for unused events
  handle_fallback()
end
```
