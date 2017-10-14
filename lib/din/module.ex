defmodule Din.Module do
  alias Din.Resources.Channel

  @moduledoc """
  Module for pluggable implementation for any application.
  """

  @doc """
  Creates a GenServer for your handler file.

  Just add `use Din.Module` at the top of your handler, and start it using `YourApplication.YourModule.start_link`.
  """
  @spec __using__(list) :: any
  defmacro __using__(_opts) do
    quote do
      import Din.Module
      use GenServer
      require Logger

      @doc """
      Starts the GenServer with default state.

      ## State Details

      - `websocket` - PID for `Din.Websocket`
      - `session_id` - session ID provided by Discord
      - `heartbeat_ack` - identifier to see if the last heartbeat sent was acknowledged by Discord
      - `heartbeat_interval` - inteveral in milliseconds to send heartbeats provided by Discord
      - `sequence` - sequence counter for heartbeats, increments by 1 every beat
      - `resume` - identifier for if the bot needs to be resumed after disconnect
      """
      def start_link do
        Logger.info "starting genserver"

        default_state = %{
          websocket: nil,
          session_id: nil,
          heartbeat_ack: true,
          heartbeat_interval: nil,
          sequence: nil,
          resume: false}

        GenServer.start_link(__MODULE__, default_state)
      end

      @doc """
      Starts the websocket connection.

      The PID for the websocket is added to the state.
      """
      def init(state) do
        {:ok, conn} = Din.Websocket.start_link(self())
        {:ok, %{state | websocket: conn}}
      end

      @doc """
      Handle's the OP 0 `READY`.

      The session ID provided is added to the state.
      """
      def handle_info({:gateway, %{op: 0, d: data, t: "READY"}}, state) do
        Logger.debug "ready"
        {:noreply, %{state | session_id: data.session_id}}
      end

      @doc """
      Default handler for OP 0 events.

      The `event` is casted to the handler, which the user implements.
      """
      def handle_info({:gateway, %{op: 0, d: data, t: event}}, state) do
        Logger.debug "#{event}" |> String.downcase
        send self(), {:event, event, data}

        {:noreply, state}
      end

      @doc """
      Handler for OP 7 `RECONNECT`.

      This sends the Gateway instructions to resume from where we left off.
      """
      def handle_info({:gateway, %{op: 7, d: data}}, state) do
        Logger.warn "reconnect"
        IO.inspect data
        send self(), :resume

        {:noreply, state}
      end

      @doc """
      Handler for OP 9 `INVALID SESSION`.

      This tells the Gateway to initiate a reconnection.
      """
      def handle_info({:gateway, %{op: 9}}, state) do
        Logger.warn "invalid session"
        send self(), :reconnect

        {:noreply, state}
      end

      @doc """
      Handler for OP 10 `HELLO`.

      This is what's received upon initial connection, where we need to `IDENTIFY` and start sending heartbeats.
      """
      def handle_info({:gateway, %{op: 10, d: data}}, state) do
        Logger.debug "hello"
        send self(), :start

        {:noreply, %{state | heartbeat_interval: data.heartbeat_interval, sequence: nil}}
      end

      @doc """
      Handler for OP 11 `HEARTBEAT ACK`.

      Discord tells us that it's acknowledged our heartbeat and it's reflected in the state.
      """
      def handle_info({:gateway, %{op: 11}}, state) do
        Logger.debug "heartbeat ack"
        {:noreply, %{state | heartbeat_ack: true}}
      end

      @doc """
      Fallback handler for unexpected ops.
      """
      def handle_info({:gateway, %{op: op}}, state) do
        Logger.warn "unused op: #{op}"
        {:noreply, state}
      end

      @doc """
      Initial steps to take after receiving OP 10 `HELLO`.

      This will `IDENTIFY` with Discord if it's the first time starting, or will attempt to `RESUME` if possible.

      This also starts sending heartbeats.
      """
      def handle_info(:start, state) do
        case state[:resume] do
          true -> send self(), :resume
          false -> send self(), :identify
        end

        send self(), :heartbeat

        {:noreply, state}
      end

      @doc """
      Handler for OP 2 `IDENTIFY`.
      """
      def handle_info(:identify, state) do
        Logger.debug "identify"
        data = %{
          token: Application.get_env(:din, :discord_token),
          properties: %{
            "$os": "elixir",
            "$browser": "din",
            "$device": "din"
          },
          compress: false,
          large_threshold: 250
        }

        WebSockex.send_frame state[:websocket], {:text, Poison.encode!(%{op: 2, d: data})}

        {:noreply, state}
      end

      @doc """
      Handler for OP 1 `HEARTBEAT`.

      This sends a heartbeat to Discord, and updates the sequence. The state is marked as `false` for `heartbeat_ack`, and will remain that way until discord sends OP 11 `HEARTBEAT ACK`.

      If Discord did not acknowledge the last heartbeat, the Gateway will close the websocket and attempt to reconnect and `RESUME`.
      """
      def handle_info(:heartbeat, state) do
        case state[:heartbeat_ack] do
          true ->
            Logger.debug "heartbeat send"
            WebSockex.send_frame state[:websocket], {:text, Poison.encode!(%{op: 1, d: state[:sequence]})}

            next_in_sequence = case state[:sequence] do
              nil -> 1
              sequence -> sequence + 1
            end

            :erlang.send_after state[:heartbeat_interval], self(), :heartbeat
            {:noreply, %{state | sequence: next_in_sequence, heartbeat_ack: false}}
          false ->
            Logger.warn "heartbeat not acknowledged"
            WebSockex.cast state[:websocket], {:close, 1001, "heartbeat not acknowledged"}
            send self(), :reconnect

            {:noreply, state}
        end
      end

      @doc """
      Handler to initiate reconnection.

      This will close the websocket process and restart it, and will update the state accordingly.
      """
      def handle_info(:reconnect, state) do
        Logger.warn "attempting reconnect"
        Process.exit(state[:websocket], :kill)
        {:ok, conn} = Din.Websocket.start_link(self())

        {:noreply, %{state | websocket: conn, heartbeat_ack: true, resume: true}}
      end

      @doc """
      Handler for OP 6 `RESUME`.

      This will ask Discord to resume from where we left off.
      """
      def handle_info(:resume, state) do
        Logger.warn "attempting resume"
        data = %{session_id: state[:session_id], seq: state[:sequence]}
        WebSockex.send_frame state[:websocket], {:text, Poison.encode!(%{op: 6, d: data})}

        {:noreply, state}
      end
    end
  end

  @doc """
  Macro to create initial handlers for Discord events.

  Events can be written as strings or atoms, whichever you prefer. Data sent by the Gateway can be interfaced with the `data` variable.

  ## Example

  ```Elixir
  handle :message_create do
    IO.inspect data.content
  end

  handle "PRESENCE_UPDATE" do
    IO.inspect data
  end
  ```
  """
  @spec handle(atom | String.t, do: any) :: {:noreply, map}
  defmacro handle(event, do: body) do
    event = cond do
      event |> is_atom -> event |> Atom.to_string |> String.upcase
      event |> is_bitstring -> event |> String.upcase
      true -> raise "Handle event must be an atom or a string."
    end

    quote do
      def handle_info({:event, unquote(event), var!(data)}, var!(state)) do
        unquote(body)
        {:noreply, var!(state)}
      end
    end
  end

  @doc """
  Macro to handle any event.

  Only use this once at the end of your handler module. Data sent by the Gateway can be interfaced with the `data` variable.
  """
  @spec handle_any(do: any) :: {:noreply, map}
  defmacro handle_any(do: body) do
    quote do
      def handle_info({:event, _event, var!(data)}, var!(state)) do
        unquote(body)
        {:noreply, var!(state)}
      end
    end
  end

  @doc """
  Macro to handle unused events.

  Place this once at the end of your handler module if you do not use `handle_any/1`.
  """
  @spec handle_fallback :: {:noreply, map}
  defmacro handle_fallback() do
    quote do
      def handle_info({:event, _event, _data}, var!(state)) do
        {:noreply, var!(state)}
      end
    end
  end

  @doc """
  Macro to create enforcement validators.

  Simply a readable version of what will expand to an if statement. The atom should be the name of a function that takes `data` as a single argument, and should evaluate to either `true` or `false`.

  ## Example

  ```Elixir
  alias Din.Resources.Channel

  handle :message_create do
    enforce :direct_message do
      match "hello", do: reply "hi!"
    end
  end

  def direct_message(data) do
    Channel.get(data.channel_id).is_private
  end
  ```
  """
  @spec enforce(atom, do: any) :: any
  defmacro enforce(validator, do: body) do
    quote do
      if unquote(validator)(var!(data)) do
        unquote(body)
      end
    end
  end

  @doc """
  Macro to match text content, as either a string or a list.

  Typically used for the `MESSAGE_CREATE` event. Matches given text with the beginning of the content sent by users using Regex.

  The second argument can either be a `do` block, or an atom of a function that takes `data` as an argument.

  ## Example

  ```Elixir
  match "!ping", do: IO.inspect data.content
  match ["!foo", "!bar"], :inspect

  ...

  def inspect(data) do
    IO.inspect data
  end
  ```
  """
  @spec match(String.t, do: any) :: any
  defmacro match(text, do: body) when is_bitstring(text) do
    quote do
      if Regex.compile!("^(#{unquote(text)})") |> Regex.match?(var!(data).content), do: unquote(body)
    end
  end

  @spec match(list(String.t), do: any) :: any
  defmacro match(texts, do: body) when is_list(texts) do
    quote do
      if Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") |> Regex.match?(var!(data).content), do: unquote(body)
    end
  end

  @spec match(String.t, atom) :: any
  defmacro match(text, body) when is_bitstring(text) do
    quote do
      if Regex.compile!("^(#{unquote(text)})") |> Regex.match?(var!(data).content), do: unquote(body)(var!(data))
    end
  end

  @spec match(list(String.t), atom) :: any
  defmacro match(texts, body) when is_list(texts) do
    quote do
      if Regex.compile!("^(#{unquote(texts) |> Enum.join("|")})") |> Regex.match?(var!(data).content), do: unquote(body)(var!(data))
    end
  end

  @doc """
  Macro to reply to messages.

  Typically used for the `MESSAGE_CREATE` event, or anything with a `channel_id` key. Will accept the same content as `Din.Resources.Channel.create_message/3`.

  ## Example

  ```Elixir
  match "!ping", do: reply "Pong!"
  ```
  """
  @spec reply(String.t, list) :: any
  defmacro reply(text, opts \\ []) do
    quote do
      Channel.create_message(var!(data).channel_id, unquote(text), unquote(opts))
    end
  end
end
