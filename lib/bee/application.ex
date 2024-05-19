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

      # Nx
      {Nx.Serving, serving: serving_text(), name: BeeTextServing},
      {Nx.Serving, serving: serving_image(), name: BeeImageServing, batch_timeout: 100},
      {Nx.Serving, serving: serving_stable_diffusion(), name: BeeStableDiffusionServing},
      {Nx.Serving, serving: serving_gpt2(), name: BeeGpt2Serving},
      {Nx.Serving, serving: serving_ner(), name: BeeNerServing},
      {Nx.Serving, serving: serving_speech(), name: BeeSpeechServing},
      {Nx.Serving, serving: serving_qa(), name: BeeQAServing},
      {Nx.Serving, serving: serving_fill_mask(), name: BeeFillMaskServing},

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
    {:ok, model_info} = Bumblebee.load_model({:hf, "microsoft/resnet-50"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "microsoft/resnet-50"})

    Bumblebee.Vision.image_classification(model_info, featurizer,
      # compile: [batch_size: 10, sequence_length: 100],
      compile: [batch_size: 10],
      defn_options: [compiler: EXLA]
    )
  end

  def serving_stable_diffusion do
    repository_id = "CompVis/stable-diffusion-v1-4"

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/clip-vit-large-patch14"})
    {:ok, clip} = Bumblebee.load_model({:hf, repository_id, subdir: "text_encoder"})

    {:ok, unet} =
      Bumblebee.load_model({:hf, repository_id, subdir: "unet"},
        params_filename: "diffusion_pytorch_model.bin"
      )

    {:ok, vae} =
      Bumblebee.load_model({:hf, repository_id, subdir: "vae"},
        architecture: :decoder,
        params_filename: "diffusion_pytorch_model.bin"
      )

    {:ok, scheduler} = Bumblebee.load_scheduler({:hf, repository_id, subdir: "scheduler"})

    {:ok, featurizer} =
      Bumblebee.load_featurizer({:hf, repository_id, subdir: "feature_extractor"})

    {:ok, safety_checker} = Bumblebee.load_model({:hf, repository_id, subdir: "safety_checker"})

    Bumblebee.Diffusion.StableDiffusion.text_to_image(clip, unet, vae, tokenizer, scheduler,
      num_steps: 20,
      num_images_per_prompt: 2,
      safety_checker: safety_checker,
      safety_checker_featurizer: featurizer,
      compile: [batch_size: 1, sequence_length: 60],
      defn_options: [compiler: EXLA]
    )
  end

  # def serving_gpt2 do
  #   {:ok, gpt2} = Bumblebee.load_model({:hf, "gpt2"})
  #   {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "gpt2"})

  #   Bumblebee.Text.generation(gpt2, tokenizer, max_new_tokens: 10)
  # end

  def serving_gpt2 do
    {:ok, gpt2} = Bumblebee.load_model({:hf, "gpt2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "gpt2"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "gpt2"})

    Bumblebee.Text.generation(gpt2, tokenizer, generation_config)
  end

  def serving_ner do
    {:ok, bert} = Bumblebee.load_model({:hf, "dslim/bert-base-NER"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-cased"})

    Bumblebee.Text.token_classification(bert, tokenizer, aggregation: :same)
  end

  defp serving_speech do
    {:ok, model_info} = Bumblebee.load_model({:hf, "openai/whisper-tiny"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "openai/whisper-tiny"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/whisper-tiny"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "openai/whisper-tiny"})

    Bumblebee.Audio.speech_to_text_whisper(model_info, featurizer, tokenizer, generation_config,
      compile: [batch_size: 10],
      defn_options: [compiler: EXLA]
    )
  end

  def serving_qa do
    {:ok, roberta} = Bumblebee.load_model({:hf, "deepset/roberta-base-squad2"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "roberta-base"})

    Bumblebee.Text.question_answering(roberta, tokenizer)
  end

  def serving_fill_mask do
    {:ok, bert} = Bumblebee.load_model({:hf, "bert-base-uncased"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "bert-base-uncased"})

    Bumblebee.Text.fill_mask(bert, tokenizer)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
