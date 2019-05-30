defmodule SeqTraceIntro.Plug do
  use Plug.Router

  plug(Plug.Telemetry, event_prefix: [:seq_trace_intro, :plug])

  plug(:match)
  plug(:dispatch)

  # Erlang's `seq_trace` module can be used to achieve cross-process
  # trace context propagation by leveraging it's `label` feature
  #
  #   http://erlang.org/doc/man/seq_trace.html
  #

  get "/trace" do
    Task.async(fn ->
      Task.async(fn ->
        # The Sequential Trace `label` is propagated for every message
        # `Task` executes it's function via message passing, so we can grab it:

        case :seq_trace.get_token(:label) do
          {:label, {:trace_id, trace_id}} ->
            :telemetry.execute([:task, :trace_id], %{trace_id: trace_id})

          _ ->
            :ignore
        end
      end)
    end)

    send_resp(conn, 200, "traced!")
  end
end
