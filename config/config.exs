# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :makeitcrash, Makeitcrash.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jV7HE4ZhOpSTWh31dg+CKj2hBQJsJelB9SeZk3Sdq+XkDzZh6956sWyfBUHJPxUQ",
  render_errors: [view: Makeitcrash.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Makeitcrash.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

#Twilio
config :ex_twilio, account_sid:   {:system, "TWILIO_ACCOUNT_SID"},
                   auth_token:    {:system, "TWILIO_AUTH_TOKEN"},
                   from_number:   System.get_env("TWILIO_FROM_NUMBER")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
