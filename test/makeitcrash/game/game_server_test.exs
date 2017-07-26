defmodule GameServerTest do
    use ExUnit.Case, async: false

    @number "3038675309"

    setup do
        Makeitcrash.StateServer.clear_state(@number)
        {:ok, _} = GameServer.start_link("test", Makeitcrash.MessageClient.Logging, @number)
        {:ok, %{}}
    end

    test "check correct guesses" do
        GameServer.guess_letter(@number, "t")
        assert {"t_ _ t", ["t"], 0, 5, :playing}  = GameServer.get_game_state(@number)
        GameServer.guess_letter(@number, "e")
        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(@number)
        GameServer.guess_letter(@number, "s")
        assert {"test", ["s", "e", "t"], 0, 5, :win} = GameServer.get_game_state(@number)
    end

    test "check incorrect guesses" do
        GameServer.guess_letter(@number, "f")
        assert {"_ _ _ _ ", ["f"], 1, 5, :playing} = GameServer.get_game_state(@number)
    end

    test "non single-letter guesses don't get added to guess or total" do
        GameServer.guess_letter(@number, "ffff")
        assert {"_ _ _ _ ", [], 0, 5, :playing} = GameServer.get_game_state(@number)
    end

    test "get game state after guess" do
        GameServer.guess_letter(@number, "t")
        GameServer.guess_letter(@number, "e")

        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(@number)
    end

    test "each guess only gets counted once" do
        GameServer.guess_letter(@number, "t")
        GameServer.guess_letter(@number, "t")
        GameServer.guess_letter(@number, "t")
        assert {"t_ _ t", ["t"], 0, 5, :playing} = GameServer.get_game_state(@number)
    end

    test "game over, losing state after too many wrong guesses" do
        GameServer.guess_letter(@number, "r")
        GameServer.guess_letter(@number, "g")
        GameServer.guess_letter(@number, "h")
        GameServer.guess_letter(@number, "c")
        GameServer.guess_letter(@number, "o")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(@number) 
    end

    test "can't keep playing after game over" do
        GameServer.guess_letter(@number, "r")
        GameServer.guess_letter(@number, "g")
        GameServer.guess_letter(@number, "h")
        GameServer.guess_letter(@number, "c")
        GameServer.guess_letter(@number, "o")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(@number)
        GameServer.guess_letter(@number, "y")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(@number)
    end

    test "game over, winning state if all letters guess correctly" do
        GameServer.guess_letter(@number, "t")
        GameServer.guess_letter(@number, "e")
        GameServer.guess_letter(@number, "p")
        GameServer.guess_letter(@number, "s")
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} = GameServer.get_game_state(@number)
        GameServer.guess_letter(@number, "u")
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} =  GameServer.get_game_state(@number)
    end

end