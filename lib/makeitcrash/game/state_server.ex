defmodule Makeitcrash.StateServer do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, %{}, name: StateServer)
    end

    def update_state(number, state) do
        GenServer.cast(StateServer, {:update, number, state})
    end

    def get_state(number) do
        GenServer.call(StateServer, {:get, number})
    end

    def handle_cast({:update, number, state}, state) do
        {:noreply, Map.merge(state, %{number => state})}
    end

    def handle_call({:get, number}, state) do
        case Map.fetch(state, number) do
            {:ok, game_state} ->
                {:reply, game_state, state}
            :error ->
                {:reply, {}, state}
        end
    end
end