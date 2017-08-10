defmodule Makeitcrash.GameSupervisor do
    use Supervisor

    alias Makeitcrash.StateServer

    def start_link do
        start = Supervisor.start_link(__MODULE__, [], name: :game_supervisor)

        # Pull children from state, if present
        StateServer.get_players
        |> Enum.map(fn (number) -> {StateServer.get_state(number), number} end )
        |> Enum.map(fn ({{to, word, guessed}, number}) -> start_game(to, number, word) end) 

        start
    end

    def start_game(to, number, word) do
        Supervisor.start_child(:game_supervisor, [word, Makeitcrash.MessageClient.Twilio, number, to])
    end

    def init(_) do
        children = [
            worker(GameServer, [])
        ]
        supervise(children, strategy: :simple_one_for_one)
    end

end 