defmodule Makeitcrash.SmsServer do
    use GenServer

    @words File.read!("lib/makeitcrash/word.txt")
        |> String.split("\n")
        |> Enum.map(&String.downcase/1)
        |> Enum.map(&String.trim/1)

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
            {"new", true} ->
                IO.puts "New game!"
                GameServer.new_game(from, get_word())
                {:noreply, state}
            {"crash", true} ->
                GameServer.crash(from)
                {:noreply, state}
            {_, true} ->
                GameServer.guess_letter(from, body)
                {:noreply, state}
            {_, false} ->
                Makeitcrash.GameSupervisor.start_game(from, get_word())
                {:noreply, MapSet.put(state, from)}
        end
    end

    defp get_word do
       @words |> Enum.random
    end
end