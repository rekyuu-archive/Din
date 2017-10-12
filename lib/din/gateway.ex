defmodule Din.Gateway do
  use GenServer
  require Logger

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

  def init(state) do
    {:ok, conn} = Din.Websocket.start_link(self())
    {:ok, %{state | websocket: conn}}
  end

  def handle_info({:gateway, %{op: 0, d: payload, t: "READY"}}, state) do
    Logger.debug "ready"
    {:noreply, %{state | session_id: payload.session_id}}
  end

  def handle_info({:gateway, %{op: 0, d: payload, t: event}}, state) do
    Logger.debug "dispatch: #{event}"
    {:noreply, state}
  end

  def handle_info({:gateway, %{op: 7, d: payload}}, state) do
    Logger.warn "reconnect"
    IO.inspect payload
    send self(), :resume

    {:noreply, state}
  end

  def handle_info({:gateway, %{op: 9}}, state) do
    Logger.warn "invalid session"
    send self(), :reconnect

    {:noreply, state}
  end

  def handle_info({:gateway, %{op: 10, d: payload}}, state) do
    Logger.debug "hello"
    send self(), :start

    {:noreply, %{state | heartbeat_interval: payload.heartbeat_interval, sequence: nil}}
  end

  def handle_info({:gateway, %{op: 11}}, state) do
    Logger.debug "heartbeat ack"
    {:noreply, %{state | heartbeat_ack: true}}
  end

  def handle_info({:gateway, %{op: op}}, state) do
    Logger.warn "unused op: #{op}"
    {:noreply, state}
  end

  def handle_info(:start, state) do
    case state[:resume] do
      true -> send self(), :resume
      false -> send self(), :identify
    end

    send self(), :heartbeat

    {:noreply, state}
  end

  def handle_info(:identify, state) do
    Logger.debug "identify"
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

    WebSockex.send_frame state[:websocket], {:text, Poison.encode!(%{op: 2, d: payload})}

    {:noreply, state}
  end

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

  def handle_info(:reconnect, state) do
    Logger.warn "attempting reconnect"
    Process.exit(state[:websocket], :kill)
    {:ok, conn} = Din.Websocket.start_link(self())

    {:noreply, %{state | websocket: conn, heartbeat_ack: true, resume: true}}
  end

  def handle_info(:resume, state) do
    Logger.warn "attempting resume"
    payload = %{session_id: state[:session_id], seq: state[:sequence]}
    WebSockex.send_frame state[:websocket], {:text, Poison.encode!(%{op: 6, d: payload})}

    {:noreply, state}
  end
end
