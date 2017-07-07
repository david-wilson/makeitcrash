defmodule Makeitcrash.Web.Router do
  use Makeitcrash.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Makeitcrash.Web do
    pipe_through :api
  end
end
