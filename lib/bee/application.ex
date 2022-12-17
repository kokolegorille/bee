defmodule Bee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BeeWeb.Telemetry,
      # Start the Ecto repository
      Bee.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bee.PubSub},
      # Start Finch
      {Finch, name: Bee.Finch},
      # {Nx.Serving, serving: serving(), name: BeeServing},
      {Nx.Serving, serving: serving_text(), name: BeeTextServing},
      {Nx.Serving, serving: serving_image(), name: BeeImageServing, batch_timeout: 100},
      # Start the Endpoint (http/https)
      BeeWeb.Endpoint
      # Start a worker by calling: Bee.Worker.start_link(arg)
      # {Bee.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def serving_text do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-emotion-analysis"},
        log_params_diff: false
      )

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    Bumblebee.Text.text_classification(model_info, tokenizer,
      compile: [batch_size: 10, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  def serving_image do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "microsoft/resnet-50"})

    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "microsoft/resnet-50"})

    Bumblebee.Vision.image_classification(model_info, featurizer,
      compile: [batch_size: 10, sequence_length: 100],
      defn_options: [compiler: EXLA]
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
