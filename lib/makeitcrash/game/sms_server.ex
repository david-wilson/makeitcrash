defmodule Makeitcrash.SmsServer do
    use GenServer

    #Client API
    def start_link do
        GenServer.start_link(__MODULE__, MapSet.new, name: MessageServer)
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
        case {String.downcase(body), MapSet.member?(state, from)} do
            {"crash", true} ->
                GameServer.crash(from)
                {:noreply, state}
            {_, true} ->
                GameServer.guess_letter(from, body)
                {:noreply, state}
            {_, false} ->
                IO.puts "New game!"
                Makeitcrash.GameSupervisor.start_game(from, "union")
                GameServer.guess_letter(from, body)
                {:noreply, MapSet.put(state, from)}
        end
    end
end