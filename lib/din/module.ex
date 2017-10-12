defmodule Din.Module do
  defmacro __using__(_opts) do
    quote do
      import Din.Module
      import Din.Gateway
      use GenServer

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
    end
  end

  defmacro handle(event, do: body) when is_atom(event) do
    event = event |> Atom.to_string |> String.upcase

    quote do
      def handle_info({:gateway, %{op: 0, d: var!(payload), t: unquote(event)}}, var!(state)) do
        unquote(body)
        {:noreply, state}
      end
    end
  end

  defmacro handle(event, do: body) when is_bitstring(event) do
    event = event |> String.upcase

    quote do
      def handle_info({:gateway, %{op: 0, d: var!(payload), t: unquote(event)}}, var!(state)) do
        unquote(body)
        {:noreply, state}
      end
    end
  end

  defmacro handle(event, do: body) do
    quote do
      def handle_info({:gateway, %{op: 0, d: var!(payload), t: unquote(event)}}, var!(state)) do
        unquote(body)
        {:noreply, state}
      end
    end
  end
end
