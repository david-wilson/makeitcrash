defmodule Makeitcrash.Web.SmsController do
    use Makeitcrash.Web, :controller

    def webhook(conn, _params) do
        %{"From" => from, "Body" => body} = conn.body_params 
        Makeitcrash.SmsHandler.handle_message(from, body)
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "")
    end
end