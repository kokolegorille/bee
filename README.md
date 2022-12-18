# Bee

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# Testing Bumblebee

On ajoute les paquets bumblebee, exla, xla

```
      {:bumblebee, "~> 0.1.2"},
      {:exla, "~> 0.4.1"},
      {:xla, "~> 0.4.3"},
```

Pour compiler xla, il faut définir des variables d'environnement.

export XLA_BUILD=true
export XLA_TARGET=cpu

Il faut les prérequis suivants.

Git
Bazel
Python3 with Numpy

Pour installer bazel...

```
asdf plugin-add bazel
asdf list all bazel
```

La dernière version stable disponible est 5.4.0, lors de l'écriture du document.

```
asdf install bazel 5.4.0
asdf global bazel 5.4.0
```

On crée le projet

```
mix phx.new bee
cd bee
```

Initialisation de git
```
git init
git add .
git commit -m "Initial commit"
```

On ajoute les dépendances, on exporte les variables. Ensuite on compile, c'est long!

```
cd bee
mix deps.get
mix compile
```





```
iex -S mix phx.server
Erlang/OTP 25 [erts-13.1.2] [source] [64-bit] [smp:24:24] [ds:24:24:10] [async-threads:1] [jit:ns]

2022-12-17 04:00:12.104992: I tensorflow/core/util/port.cc:104] oneDNN custom operations are on. You may see slightly different numerical results due to floating-point round-off errors from different computation orders. To turn them off, set the environment variable `TF_ENABLE_ONEDNN_OPTS=0`.
|====================================================================================================| 100% (539.70 MB)
[info] TfrtCpuClient created.
|====================================================================================================| 100% (2.91 MB)
[info] Running BeeWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access BeeWeb.Endpoint at http://localhost:4000
Interactive Elixir (1.14.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> [watch] build finished, watching for changes...

Rebuilding...
Done in 154ms.
```


## Test Stable Diffusion

```
iex(1)> text = "numbat, forest, high quality, detailed, digital art"
"numbat, forest, high quality, detailed, digital art"
iex(2)> negative_text = "darkness, rainy, foggy"
"darkness, rainy, foggy"
iex(3)> result = Nx.Serving.batched_run(BeeStableDiffusionServing, %{prompt: text, negative_prompt: negative_text})
%{
  results: [
    %{
      image: #Nx.Tensor<
        u8[512][512][3]
        EXLA.Backend<host:0, 0.3536702673.2258239536.2772>
        [
          [
            [75, 103, 11],
            [68, 107, 0],
            [64, 109, 0],
            [63, 110, 0],
            [62, 107, 0],
            [61, 110, 0],
            [61, 110, 0],
            [60, 110, 0],
            [60, 110, 0],
            [60, 110, 0],
            [61, 109, 0],
            [61, 109, 0],
            [61, 109, 0],
            [60, 108, 0],
            [60, 109, 0],
            [60, 109, ...],
            ...
          ],
          ...
        ]
      >,
      is_safe: true
    },
    %{
      image: #Nx.Tensor<
        u8[512][512][3]
        EXLA.Backend<host:0, 0.3536702673.2258239536.2779>
        [
          [
            [134, 147, 98],
            [132, 148, 91],
            [132, 151, 92],
            [129, 150, 91],
            [129, 147, 89],
            [129, 147, 89],
            [127, 146, 89],
            [130, 149, 89],
            [127, 146, 86],
            [126, 145, 83],
            [129, 149, 87],
            [126, 146, 85],
            [122, 142, 81],
            [126, 146, 84],
            [124, 143, 82],
            [125, ...],
            ...
          ],
          ...
        ]
      >,
      is_safe: true
    }
  ]
}
iex4> result.results |> Enum_with_index() |> Enum.each(fn -> {r, index} 
  {:ok, image} = Image.from_nx(r.image)
  Imge.write(image, "test/fixtures/test_#{index}.jpg", suffix: :jpg)
end)
```