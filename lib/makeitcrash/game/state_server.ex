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

    def clear_state(number) do
        GenServer.cast(StateServer, {:update, number, {}})
    end

    def get_players do
        GenServer.call(StateServer, :get_players)
    end

    def handle_cast({:update, number, player_state}, state) do
        {:noreply, Map.merge(state, %{number => player_state})}
    end

    def handle_call({:get, number}, _from, state) do
        case Map.fetch(state, number) do
            {:ok, game_state} ->
                {:reply, game_state, state}
            :error ->
                {:reply, {}, state}
        end
    end

    def handle_call(:get_players, _from, state) do
        {:reply, Map.keys(state), state}
    end
end