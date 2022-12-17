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



