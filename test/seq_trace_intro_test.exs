defmodule SeqTraceIntroTest do
  use ExUnit.Case
  doctest SeqTraceIntro

  test "greets the world" do
    :httpc.request('http://localhost:4001/hello')
    |> IO.inspect()
  end
end
