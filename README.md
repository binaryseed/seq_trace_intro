# SeqTraceIntro

This app serves as a small demo of putting together:

* `Plug`
* `telemetry`
* `seq_trace`

A test adds a few `telemetry` handlers, the first of which will _start_ a `seq_trace` inside our request process:

* [test/seq_trace_intro_test.exs](https://github.com/binaryseed/seq_trace_intro/blob/master/test/seq_trace_intro_test.exs#L16-L20)

The plug spawns a few nested `Task`s and is able to fetch the cross-process trace context:

* [lib/seq_trace_intro/plug.ex](https://https://github.com/binaryseed/seq_trace_intro/blob/master/lib/seq_trace_intro/plug.ex#L21)
