defmodule GameServer do
    use GenServer

    require Logger

    @num_guesses 7

    # Client API
    def start_link(word, client, number, to) do
        name = via_tuple(number)
        GenServer.start_link(__MODULE__, %{ word: word, 
                                            guessed: [], 
                                            message_client: client, 
                                            number: number,
                                            to: to},
                                            name: name)
    end

    defp via_tuple(number) do
        {:via, Registry, {:game_process_registry, number}}
    end

    def get_game_state(number) do
        GenServer.call(via_tuple(number), :get_state)
    end

    def guess_letter(number, guess) do
        GenServer.cast(via_tuple(number), {:guess, String.downcase(guess)})
    end

    def crash(number) do
        Logger.info "Crashing #{Kernel.inspect self()}"
        [{pid, _}] = Registry.lookup(:game_process_registry, number)
        Process.exit(pid, :kill)
    end

    def new_game(number, word) do
        GenServer.cast(via_tuple(number), {:new_game, word})
    end

    # Server
    def init(core_state) do
        state =
            case Makeitcrash.StateServer.get_state(core_state.number) do
                {to, word, guessed} ->
                    %{core_state | guessed: guessed, word: word, to: to}
                _ ->
                    core_state
            end
        IO.puts "GOT STATE"
        Makeitcrash.StateServer.update_state(core_state.number, {state.to, state.word, state.guessed})
        send self(), {:lazy_init}
        game_state = game_state_from_core(state)
        {:ok, game_state}
    end

    def handle_info({:lazy_init}, state) do
        pid = inspect self()
        message = "Hello from #{pid}! Send a letter to make a guess."
        IO.puts message
        state.message_client.send_message(message, state.number, state.to)
        send_state_message(state)
        {:noreply, state}
    end

    def handle_call(:get_state, _from, state) do
        {:reply, user_state(state, compute_winning_state(state)), state}
    end

    def handle_cast({:guess, guess}, state) do
        {user_state, state} = get_reply(state, guess)
        Makeitcrash.StateServer.update_state(state.number, {state.to, state.word, state.guessed})
        user_state
        |> render_game(state.word)
        |> state.message_client.send_message(state.number, state.to)
        {:noreply, state}
    end  

    def handle_cast({:new_game, word}, state) do
        new_state = %{ word: word,
                       guessed: [],
                       message_client: state.message_client,
                       number: state.number,
                       to: state.to}
                       |> game_state_from_core

        Makeitcrash.StateServer.update_state(new_state.number,
             {new_state.to, new_state.word, new_state.guessed})

        "Starting new game"
        |> new_state.message_client.send_message(new_state.number, new_state.to)

        send_state_message(new_state)
        {:noreply, new_state}
    end

    defp get_reply(state, guess) do
        status = compute_winning_state(state) 
        new_state = update_state(state, guess)

        case {status, compute_winning_state(new_state)} do
            {:win,_} ->
                {user_state(state, :win), state}
            {:lose,_} ->
                {user_state(state, :lose), state}
            {_, :win} ->
                {user_state(new_state, :win), new_state}
            {_, :lose} -> 
                {user_state(new_state, :lose), new_state}
            _ ->
                {user_state(new_state, :playing), new_state}
        end
    end

    defp render_game({progress, guessed_list, guessed, total, state} = game_tuple, word) do
        case state do
            :playing ->
                rendered_list = inspect(guessed_list)
                "#{progress}, #{guessed}/#{total} guesses, #{rendered_list}"
            :win ->
                "You won! Word is \"#{word}\". Reply \"new\" for new game."
            :lose ->
                "Game over! Word was \"#{word}\". Reply \"new\" for new game."
        end
    end

    defp update_state(state, guess) do
        single_char_guess = String.length(guess) == 1
        new_guess = !MapSet.member?(state.guessed_set, guess)
        valid_guess = single_char_guess && new_guess

        case valid_guess do        
            true ->
                guessed_set = MapSet.put(state.guessed_set, guess)
                %{state | guessed: [guess | state.guessed], 
                            guessed_set: guessed_set,
                            num_wrong: get_num_wrong(state.letter_set, guessed_set)}
            _ ->
                state
        end
    end

    defp compute_winning_state(state) do
        under_guesses? = state.num_wrong < @num_guesses 
        guessed_word? = MapSet.subset?(state.letter_set, state.guessed_set)
        case {under_guesses?, guessed_word?} do
            {true, false} ->
                :playing
            {true, true} ->
                :win
            {false, false} ->
                :lose
            {false, true} ->
                :win
        end
    end

    defp game_state_from_core(core_state) do
      letter_set = core_state.word
                |> String.graphemes
                |> MapSet.new
      guessed_set = core_state.guessed |> MapSet.new
      Map.merge(core_state, %{letter_set: letter_set, 
                              guessed_set: guessed_set, 
                              num_wrong: get_num_wrong(letter_set, guessed_set)
                              })
    end

    defp get_num_wrong(letter_set, guessed_set) do
      num_guessed = MapSet.size(guessed_set)
      num_guessed - MapSet.size(MapSet.intersection(letter_set, guessed_set))  
    end

    defp user_state(state, status) do 
        {render_filled_word(state.word, state.guessed_set), state.guessed, state.num_wrong, @num_guesses, status}
    end

    defp send_state_message(state) do
        IO.puts "Sending message"
        user_state(state, :playing)
        |> render_game(state.word)
        |> state.message_client.send_message(state.number, state.to)
    end

    defp render_filled_word(word, guessed_set) do
        word
        |> String.graphemes
        |> Enum.map(fn grapheme -> if MapSet.member?(guessed_set, grapheme), do: grapheme, else: "_ " end)
        |> Enum.join
    end
    
    end