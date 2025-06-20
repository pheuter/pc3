import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pc3, Pc3Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Xchf2MVqoHjpimIkYphYd+eKkxUsZuQcepFHVcVpqXXNBMQNwQ1TK422XJTrZOoY",
  server: false

# In test we don't send emails
config :pc3, Pc3.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure test database
config :pc3, Pc3.Repo,
  database: Path.expand("../priv/pc3_test.db", __DIR__),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
