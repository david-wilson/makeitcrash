defmodule Makeitcrash.MessageClient.Twilio do
    def send_message(body, number) do
         message = %ExTwilio.Message{from: Application.get_env(:ex_twilio, :from_number),
                                    to: number,
                                    body: body}
        {:ok, _} = ExTwilio.Message.create(message)
    end
end