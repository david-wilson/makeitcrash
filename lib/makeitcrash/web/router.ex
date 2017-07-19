defmodule Makeitcrash.Web.Router do
  use Makeitcrash.Web, :router

  pipeline :api do
    plug :accepts, ["json", "x-www-form-urlencoded"]
  end

  scope "/api", Makeitcrash.Web do
    pipe_through :api

    post "/webhook", SmsController, :webhook
  end
end
