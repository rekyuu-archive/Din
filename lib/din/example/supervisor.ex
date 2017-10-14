defmodule Din.Example.Supervisor do
  use Application
  use Supervisor
  require Logger

  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info "starting supervisor"

    children = [worker(Din.Example, [])]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
