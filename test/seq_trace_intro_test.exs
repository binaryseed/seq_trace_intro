defmodule SeqTraceIntroTest do
  use ExUnit.Case
  doctest SeqTraceIntro

  test "Cross process Trace ID propigation" do
    trace_id = :rand.uniform() |> inspect()
    test_pid = self()

    :telemetry.attach_many(
      :seq_trace_intro,
      [
        [:seq_trace_intro, :plug, :start],
        [:task, :trace_id]
      ],
      fn
        [:seq_trace_intro, :plug, :start], _measurements, _metadata, _config ->
          # Start a Sequential Trace inside a `telemetry` handler
          # by setting a `label`, which can be any term:

          :seq_trace.set_token(:label, {:trace_id, trace_id})

        [:task, :trace_id] = event, measurements, metadata, config ->
          send(test_pid, {event, measurements, metadata, config})
      end,
      %{}
    )

    :httpc.request('http://localhost:4001/trace')

    # The Trace ID was available inside the nested Task!
    assert_receive {[:task, :trace_id], %{trace_id: task_trace_id}, _, _}
    assert trace_id == task_trace_id
  end
end
