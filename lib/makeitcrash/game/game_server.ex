defmodule GameServer do
    use GenServer

    @num_guesses 5

    # Client API
    def start_link(word) do
        GenServer.start_link(__MODULE__, %{word: word, guessed: []})
    end

    def get_game_state(pid) do 
        GenServer.call(pid, :get_state)
    end

    def guess_letter(pid, guess) do
        GenServer.call(pid, {:guess, String.downcase(guess)})
    end

    # Server
    def init(core_state) do
        #TODO: build server state from "core" state: word, letters guessed, player ID
        {:ok, game_state_from_core(core_state)}
    end

    def handle_call(:get_state, _from, state) do
        {:reply, user_state(state, compute_winning_state(state)), state}
    end

    def handle_call({:guess, guess}, _from, state) do
        status = compute_winning_state(state) 
        new_state = update_state(state, guess)
        case {status, compute_winning_state(new_state)} do
            {:win,_} ->
                {:reply, user_state(state, :win), state}
            {:lose,_} ->
                {:reply, user_state(state, :lose), state}
            {_, :win} ->
                {:reply, user_state(new_state, :win), new_state}
            {_, :lose} -> 
                {:reply, user_state(new_state, :lose), new_state}
            _ ->
                {:reply, user_state(new_state, :playing), new_state}
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

    defp render_filled_word(word, guessed_set) do
        word
        |> String.graphemes
        |> Enum.map(fn grapheme -> if MapSet.member?(guessed_set, grapheme), do: grapheme, else: "_ " end)
        |> Enum.join
    end
    

    end