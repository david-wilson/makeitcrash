# Makeitcrash
"Make it crash" code from my talk at [Develop Denver 2017](https://developdenver.org/). Implements a simple number guessing game over SMS to demonstrate Elixir supervisor behavior. Slides are included in the PDF in the repository root.

## Running
You will need Twilio API keys to run this project. Set them up in your enviroment as outlined in the "Configuration" section of the ExTwilio project [README](https://github.com/danielberkompas/ex_twilio).

You will also need to configure an SMS webhook for your Twilio SMS number/numbers at:
`POST {internet addressable hostname}/api/webhook`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`



