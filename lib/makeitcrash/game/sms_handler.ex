defmodule Makeitcrash.SmsHandler do

    @words File.read!("lib/makeitcrash/word.txt")
        |> String.split("\n")
        |> Enum.map(&String.downcase/1)
        |> Enum.map(&String.trim/1)

    def handle_message(from, body) do
       game_started = case Makeitcrash.StateServer.get_state(from) do
                {word, guessed} ->
                    true
                state ->
                    IO.puts "State: #{Kernel.inspect state}"
                    false
            end
        case {String.downcase(body), game_started} do
            {"new", true} ->
                IO.puts "New game!"
                GameServer.new_game(from, get_word())
            {"crash", true} ->
                GameServer.crash(from)
            {_, true} ->
                IO.puts "Guessing #{body}"
                GameServer.guess_letter(from, body)
            {_, false} ->
                IO.puts "Starting fresh game"
                Makeitcrash.GameSupervisor.start_game(from, get_word())
        end
    end

    defp get_word do
       @words |> Enum.random
    end
end