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

    # Server callbacks
    def init(core_state) do
        {:ok, core_state}
    end

    def handle_cast({:message, from, body}, state) do
        case Map.fetch(state, from) do
            {:ok, player_pid} ->
                GameServer.guess_letter(player_pid, body)
                |> render_game 
                |> send_message(from)
                {:noreply, state}
            :error -> 
                IO.puts "New game!"
                {:ok, player_pid} = GameServer.start_link("union")
                GameServer.guess_letter(player_pid, body)
                |> render_game 
                |> send_message(from)
                {:noreply, Map.merge(state, %{from => player_pid})}
        end
    end

    defp render_game({progress, guessed_list, guessed, total, state} = game_tuple) do
        rendered_list = inspect(guessed_list)
        "#{progress}, #{guessed}/#{total} guesses, #{rendered_list}"
    end

    defp send_message(body, number) do
        message = %ExTwilio.Message{from: Application.get_env(:ex_twilio, :from_number),
                                    to: number,
                                    body: body}
        {:ok, message_resource} = ExTwilio.Message.create(message)
    end
end