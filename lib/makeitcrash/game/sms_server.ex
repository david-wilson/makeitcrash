defmodule Makeitcrash.SmsServer do
    use GenServer

    #Client API
    def start_link do
        GenServer.start_link(__MODULE__, %{players: %{}}, name: MessageServer)
    end

    def handle_message( number, body) do
        # Receive text message, and either:
        # 1. Start new game
        # 3. Receive move and route to game process
        #send_message(number, "#{body} to you as well!")
        GenServer.cast(MessageServer, {:message, number, body})
    end

    defp update_game(number, game_state) do
        GenServer.cast(MessageServer, {:update, number, game_state})
    end

    # Server callbacks
    def init(core_state) do
        {:ok, core_state}
    end

    def handle_cast({:update, number, game_state}, state) do
       #TODO: update state store 
    end

    def handle_cast({:message, from, body}, state) do
        case Map.fetch(state, from) do
            {:ok, player_pid} ->
                GameServer.guess_letter(player_pid, body, from)
                {:noreply, state}
            :error -> 
                IO.puts "New game!"
                {:ok, player_pid} = GameServer.start_link("union", 
                    Makeitcrash.MessageClient.Twilio)
                GameServer.guess_letter(player_pid, body, from)
                {:noreply, Map.merge(state, %{from => player_pid})}
        end
    end
end