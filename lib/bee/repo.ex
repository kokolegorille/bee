defmodule Bee.Repo do
  use Ecto.Repo,
    otp_app: :bee,
    adapter: Ecto.Adapters.Postgres
end
