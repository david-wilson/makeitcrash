defmodule Makeitcrash.MessageClient.Logging do
    require Logger

    def send_message(body, number) do
        Logger.info "Sent #{body} to #{number}"
    end
end
