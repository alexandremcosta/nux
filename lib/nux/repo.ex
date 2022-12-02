defmodule Nux.Repo do
  use Ecto.Repo,
    otp_app: :nux,
    adapter: Ecto.Adapters.Postgres
end
