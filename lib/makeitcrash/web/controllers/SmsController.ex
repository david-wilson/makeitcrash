defmodule Makeitcrash.Web.SmsController do
    use Makeitcrash.Web, :controller

    def webhook(conn, _params) do
        %{"From" => from, "Body" => body} = conn.body_params 
        Makeitcrash.SmsServer.handle_message(from, body)
        send_resp(conn, 200, "")
    end
end