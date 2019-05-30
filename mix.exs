defmodule SeqTraceIntro.MixProject do
  use Mix.Project

  def project do
    [
      app: :seq_trace_intro,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SeqTraceIntro.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:telemetry, "~> 0.4"}
    ]
  end
end
