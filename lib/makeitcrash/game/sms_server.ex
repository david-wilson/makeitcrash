defmodule Makeitcrash.SmsServer do
    use GenServer

    #Client API
    def start_link do
        GenServer.start_link(__MODULE__, %{players: MapSet.new}, name: MessageServer)
    end

    def handle_message( number, body) do
        # Receive text message, and either:
        # 1. Start new game
        # 3. Receive move and route to game process
        #send_message(number, "#{body} to you as well!")
        GenServer.cast(MessageServer, {:message, number, body})
    end

    # Server callbacks
    def init(core_state) do
        {:ok, core_state}
    end

    def handle_cast({:message, from, body}, state) do
        case MapSet.member?(state.players, from) do
            true ->
                GameServer.guess_letter(from, body)
                {:noreply, state}
            false ->
                IO.puts "New game!"
                {:ok, _} = GameServer.start_link("union",
                    Makeitcrash.MessageClient.Twilio, from)
                GameServer.guess_letter(from, body)
                {:noreply, MapSet.put(state.players, from)}
        end
    end
end