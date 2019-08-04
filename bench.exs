# mix run bench.exs

defmodule TheToken do
  @token %{
    trace_id: "0975d5ceea29b032",
    padding: for(n <- 0..20, do: n),
    attribute: "value"
  }
  def token, do: @token

  IO.inspect({:token_size, :erts_debug.size(@token) * 8, :bytes})
end

defmodule HardCoded.Propigator do
  @moduledoc """
  This propigator just returns the hard coded value

  This is intended to provide a baseline which does no work
  in order to propigate the token.
  """
  def run(%{trace_id: trace_id}) do
    child = spawn(__MODULE__, :child_worker, [self()])

    send(child, :trace_id_please)

    receive do
      %{trace_id: ^trace_id} -> :got_it
    end
  end

  def child_worker(parent) do
    receive do
      :trace_id_please ->
        send(parent, TheToken.token())
    end
  end
end

defmodule SeqTrace.Propigator do
  @moduledoc """
  This propigator uses a `seq_trace` label so that the token
  flows alongside every message passed

  Requires no code changes since it's built into the BEAM
  """
  def run(%{trace_id: trace_id} = token) do
    :seq_trace.set_token(:label, token)

    child = spawn(__MODULE__, :child_worker, [self()])

    send(child, :trace_id_please)

    receive do
      %{trace_id: ^trace_id} -> :got_it
    end
  end

  def child_worker(parent) do
    receive do
      :trace_id_please ->
        case :seq_trace.get_token(:label) do
          {:label, token} ->
            send(parent, token)
        end
    end
  end
end

defmodule Pdict.Propigator do
  @moduledoc """
  This propigator stores the token inside the process dictionary
  for later retrieval

  Requires manual instrumentation at every process bountary
  """
  def run(%{trace_id: trace_id} = token) do
    parent = self()

    child =
      spawn(fn ->
        Process.put(:token, token)
        child_worker(parent)
      end)

    send(child, :trace_id_please)

    receive do
      %{trace_id: ^trace_id} -> :got_it
    end
  end

  def child_worker(parent) do
    receive do
      :trace_id_please ->
        send(parent, Process.get(:token))
    end
  end
end

Benchee.run(
  %{
    "hard coded control" => &HardCoded.Propigator.run/1,
    "seq_trace label" => &SeqTrace.Propigator.run/1,
    "process dictionary storage" => &Pdict.Propigator.run/1
  },
  inputs: %{TheToken.token().trace_id => TheToken.token()},
  parallel: 1
)
