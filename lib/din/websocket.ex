defmodule Din.Websocket do
  use GenServer
  require Logger

  @gateway "gateway.discord.gg"

  def start_link do
    Logger.info "Connecting websocket..."
    url = "gateway.discord.gg"
    path = "/?v=6&encoding=json"
    conn = Socket.Web.connect! url, path: path, secure: true

    default_state = %{
      conn: conn,
      session_id: nil,
      heartbeat_ack: true,
      heartbeat_interval: nil,
      sequence: nil}

    GenServer.start_link(__MODULE__, default_state)
  end

  def init(state) do
    send self(), :receive
    {:ok, state}
  end

  def handle_info(:receive, state) do
    case Socket.Web.recv!(state[:conn]) do
      {:text, message} ->
        message = message |> Poison.Parser.parse!(keys: :atoms)
        send self(), {:gateway, message}
      {:close, :normal, _reason} ->
        Logger.warn "websocket closed"
        send self(), :reconnect
      _ -> nil
    end

    :erlang.send_after(100, self(), :receive)
    {:noreply, state}
  end

  def handle_info({:gateway, %{d: payload, op: 0, t: "READY"}}, state) do
    Logger.debug "ready"
    {:noreply, %{state | session_id: payload.session_id}}
  end

  def handle_info({:gateway, %{d: payload, op: 0, t: event}}, state) do
    Logger.debug "dispatch: #{event}"
    {:noreply, state}
  end

  def handle_info({:gateway, %{d: payload, op: 7}}, state) do
    Logger.warn "reconnect"
    send self(), :resume

    {:noreply, state}
  end

  def handle_info({:gateway, %{d: payload, op: 10}}, state) do
    Logger.debug "hello"
    send self(), :identify

    {:noreply, %{state | heartbeat_interval: payload.heartbeat_interval, sequence: nil}}
  end

  def handle_info({:gateway, %{op: 11}}, state) do
    Logger.debug "heartbeat ack"
    {:noreply, %{state | heartbeat_ack: true}}
  end

  def handle_info({:gateway, %{d: payload, op: op}}, state) do
    Logger.debug "op #{op}"
    {:noreply, state}
  end

  def handle_info(:identify, state) do
    Logger.debug "identifying"
    payload = %{
      token: Application.get_env(:din, :discord_token),
      properties: %{
        "$os": "elixir",
        "$browser": "din",
        "$device": "din"
      },
      compress: false,
      large_threshold: 250
    }

    Socket.Web.send! state[:conn], {:text, Poison.encode!(%{op: 2, d: payload})}
    send self(), :heartbeat

    {:noreply, state}
  end

  def handle_info(:heartbeat, state) do
    case state[:heartbeat_ack] do
      true ->
        Logger.debug "heartbeat send"
        Socket.Web.send! state[:conn], {:text, Poison.encode!(%{op: 1, d: state[:sequence]})}

        next_in_sequence = case state[:sequence] do
          nil -> 1
          sequence -> sequence + 1
        end

        :erlang.send_after state[:heartbeat_interval], self(), :heartbeat
        {:noreply, %{state | sequence: next_in_sequence, heartbeat_ack: false}}
      false ->
        Socket.Web.close(state[:conn])
        send self(), :reconnect

        {:noreply, state}
    end
  end

  def handle_info(:reconnect, state) do
    Logger.debug "attempting reconnect"

    url = "gateway.discord.gg"
    path = "/?v=6&encoding=json"
    conn = Socket.Web.connect! url, path: path, secure: true
    send self(), :receive

    {:noreply, %{state | conn: conn}}
  end

  def handle_info(:resume, state) do
    Logger.warn "attempting resume"
    payload = %{token: nil, session_id: state[:session_id], seq: state[:sequence]}
    Socket.Web.send! state[:conn], {:text, Poison.encode!(%{op: 6, d: payload})}

    {:noreply, state}
  end
end
