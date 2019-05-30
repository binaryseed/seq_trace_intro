defmodule SeqTraceIntro.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: SeqTraceIntro.Plug, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: SeqTraceIntro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
