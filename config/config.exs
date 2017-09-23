# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mehr_schulferien,
  ecto_repos: [MehrSchulferien.Repo]

# Configures the endpoint
config :mehr_schulferien, MehrSchulferienWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VJ8QZiKV9Kg1PWOgnNjNv6RVbz+PLlUgCsPVQrbJSxhpM4EKKz8Lto8ErvavOXvO",
  render_errors: [view: MehrSchulferienWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MehrSchulferien.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"