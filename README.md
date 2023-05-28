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
iex4> result.results |> Enum_with_index() |> Enum.each(fn {r, index} ->
  {:ok, image} = Image.from_nx(r.image)
  Imge.write(image, "test/fixtures/test_#{index}.jpg")
end)
```

Un autre exemple.

```
iex(5)> text = "Mbappe, Messi, footbal"                                                                                                       "Mbappe, Messi, footbal"                  
iex(6)> negative_text = "world, cup, France, Argentine"                                                                                       "world, cup, France, Argentine"           
iex(7)> result = Nx.Serving.batched_run(BeeStableDiffusionServing, %{prompt: text, negative_prompt: negative_text})                           %{                                        
  results: [
    %{
      image: #Nx.Tensor<
        u8[512][512][3]
        EXLA.Backend<host:0, 0.2961323227.3131441200.146360>
        [
          [
            [86, 73, 51],
            [87, 72, 47],
            [84, 69, 44],
            [89, 76, 50],
            [87, 71, 45],
            [87, 72, 45],
            [86, 71, 46],
            [86, 72, 47],
            [86, 71, 44],
            [89, 74, 47],
            [87, 72, 44],
            [88, 73, 46],
            [87, 73, 47],
            [85, 71, 45],
            [86, 71, 47],
            [84, 71, ...],
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
        EXLA.Backend<host:0, 0.2961323227.3131441200.146364>
        [
          [
            [108, 125, 85],
            [103, 123, 75],
            [108, 131, 79],
            [98, 122, 70],
            [106, 130, 76],
            [107, 132, 77],
            [104, 130, 76],
            [104, 129, 75],
            [102, 128, 74],
            [100, 127, 73],
            [96, 122, 67],
            [101, 129, 75],
            [90, 116, 62],
            [93, 121, 66],
            [96, 122, 67],
            [98, ...],
            ...
          ],
          ...
        ]
      >,
      is_safe: true
    }
  ]
}
iex(8)> result.results |> Enum.with_index() |> Enum.each(fn {r, index} -> {:ok, image} = Image.from_nx(r.image); Image.write(image, "test/fixtures/foot_#{index}.jpg") end)
:ok
```

## Update Phoenix

* Update Phoenix 1.7.2 (from 1.7.0-rc0)
* Remove GPT2 example
* Add speech to text example

### Changes

```
$ git status
Sur la branche main
Votre branche est à jour avec 'origin/main'.

Modifications qui ne seront pas validées :
  (utilisez "git add/rm <fichier>..." pour mettre à jour ce qui sera validé)
  (utilisez "git restore <fichier>..." pour annuler les modifications dans le répertoire de travail)
	modifié :         README.md
	modifié :         assets/js/app.js
	modifié :         lib/bee/application.ex
	modifié :         lib/bee_web/components/layouts/app.html.heex
	modifié :         lib/bee_web/components/layouts/root.html.heex
	supprimé :        lib/bee_web/live/text_generation.ex
	modifié :         lib/bee_web/router.ex
	modifié :         mix.exs
	modifié :         mix.lock

Fichiers non suivis:
  (utilisez "git add <fichier>..." pour inclure dans ce qui sera validé)
	assets/js/hooks/Microphone.js
	lib/bee_web/live/speech_live.ex
	lib/bee_web/live/text_generation_live.ex
```

## Update Styles

Fix Templates rendering.

### Changes

```
$ git status
Sur la branche main
Votre branche est à jour avec 'origin/main'.

Modifications qui ne seront pas validées :
  (utilisez "git add <fichier>..." pour mettre à jour ce qui sera validé)
  (utilisez "git restore <fichier>..." pour annuler les modifications dans le répertoire de travail)
	modifié :         README.md
	modifié :         lib/bee_web/controllers/page_html/home.html.heex
	modifié :         lib/bee_web/live/image_live.ex
	modifié :         lib/bee_web/live/speech_live.ex
```

