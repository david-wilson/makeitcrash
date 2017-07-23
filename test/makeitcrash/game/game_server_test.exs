defmodule GameServerTest do
    use ExUnit.Case, async: true

    @number "3038675309"

    setup do
        {:ok, pid} = GameServer.start_link("test", Makeitcrash.MessageClient.Logging, @number)
        {:ok, pid: pid}
    end

    test "check correct guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "t")
        assert {"t_ _ t", ["t"], 0, 5, :playing}  = GameServer.get_game_state(pid)  
        GameServer.guess_letter(pid, "e") 
        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(pid)      
        GameServer.guess_letter(pid, "s") 
        assert {"test", ["s", "e", "t"], 0, 5, :win} = GameServer.get_game_state(pid)       
    end

    test "check incorrect guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "f")
        assert {"_ _ _ _ ", ["f"], 1, 5, :playing} = GameServer.get_game_state(pid) 
    end

    test "non single-letter guesses don't get added to guess or total", %{pid: pid} do
        GameServer.guess_letter(pid, "ffff")
        assert {"_ _ _ _ ", [], 0, 5, :playing} = GameServer.get_game_state(pid) 
    end

    test "get game state after guess", %{pid: pid} do
        GameServer.guess_letter(pid, "t") 
        GameServer.guess_letter(pid, "e")

        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(pid) 
    end

    test "each guess only gets counted once", %{pid: pid} do
        GameServer.guess_letter(pid, "t")
        GameServer.guess_letter(pid, "t")
        GameServer.guess_letter(pid, "t")
        assert {"t_ _ t", ["t"], 0, 5, :playing} = GameServer.get_game_state(pid)
    end

    test "game over, losing state after too many wrong guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "r")
        GameServer.guess_letter(pid, "g")
        GameServer.guess_letter(pid, "h")
        GameServer.guess_letter(pid, "c")
        GameServer.guess_letter(pid, "o")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid) 
    end

    test "can't keep playing after game over", %{pid: pid} do
        GameServer.guess_letter(pid, "r")
        GameServer.guess_letter(pid, "g")
        GameServer.guess_letter(pid, "h")
        GameServer.guess_letter(pid, "c")
        GameServer.guess_letter(pid, "o")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid)
        GameServer.guess_letter(pid, "y")
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid)
    end

    test "game over, winning state if all letters guess correctly", %{pid: pid} do
        GameServer.guess_letter(pid, "t")
        GameServer.guess_letter(pid, "e")
        GameServer.guess_letter(pid, "p")
        GameServer.guess_letter(pid, "s")
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} = GameServer.get_game_state(pid)
        GameServer.guess_letter(pid, "u")
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} =  GameServer.get_game_state(pid)
    end

end