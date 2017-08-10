defmodule Makeitcrash.MessageClient.Twilio do
    def send_message(body, number, twilio_number) do
         message = %ExTwilio.Message{from: twilio_number,
                                    to: number,
                                    body: body}
        {:ok, _} = ExTwilio.Message.create(message)
    end
end