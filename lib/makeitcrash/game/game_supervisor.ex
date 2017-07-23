defmodule Makeitcrash.GameSupervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, [], name: :game_supervisor)
    end

    def start_game(number, word) do
        Supervisor.start_child(:game_supervisor, [word, Makeitcrash.MessageClient.Twilio, number])
    end

    def init(_) do
        children = [
            worker(GameServer, [])
        ]
        supervise(children, strategy: :simple_one_for_one)
    end
end 