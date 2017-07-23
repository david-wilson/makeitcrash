defmodule GameServerTest do
    use ExUnit.Case, async: true

    @number "3038675309"

    setup do
        {:ok, pid} = GameServer.start_link("test", Makeitcrash.MessageClient.Logging)
        {:ok, pid: pid}
    end

    test "check correct guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "t", @number)      
        assert {"t_ _ t", ["t"], 0, 5, :playing}  = GameServer.get_game_state(pid, @number)  
        GameServer.guess_letter(pid, "e", @number) 
        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(pid, @number)      
        GameServer.guess_letter(pid, "s", @number) 
        assert {"test", ["s", "e", "t"], 0, 5, :win} = GameServer.get_game_state(pid, @number)       
    end

    test "check incorrect guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "f", @number)   
        assert {"_ _ _ _ ", ["f"], 1, 5, :playing} = GameServer.get_game_state(pid, @number) 
    end

    test "non single-letter guesses don't get added to guess or total", %{pid: pid} do
        GameServer.guess_letter(pid, "ffff", @number)
        assert {"_ _ _ _ ", [], 0, 5, :playing} = GameServer.get_game_state(pid, @number) 
    end

    test "get game state after guess", %{pid: pid} do
        GameServer.guess_letter(pid, "t", @number)      
        GameServer.guess_letter(pid, "e", @number)

        assert {"te_ t", ["e", "t"], 0, 5, :playing} = GameServer.get_game_state(pid, @number) 
    end

    test "each guess only gets counted once", %{pid: pid} do
        GameServer.guess_letter(pid, "t", @number)      
        GameServer.guess_letter(pid, "t", @number)      
        GameServer.guess_letter(pid, "t", @number)      
        assert {"t_ _ t", ["t"], 0, 5, :playing} = GameServer.get_game_state(pid, @number) 
    end

    test "game over, losing state after too many wrong guesses", %{pid: pid} do
        GameServer.guess_letter(pid, "r", @number)      
        GameServer.guess_letter(pid, "g", @number)      
        GameServer.guess_letter(pid, "h", @number)      
        GameServer.guess_letter(pid, "c", @number)      
        GameServer.guess_letter(pid, "o", @number)      
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid, @number) 
    end

    test "can't keep playing after game over", %{pid: pid} do
        GameServer.guess_letter(pid, "r", @number)      
        GameServer.guess_letter(pid, "g", @number)      
        GameServer.guess_letter(pid, "h", @number)      
        GameServer.guess_letter(pid, "c", @number)      
        GameServer.guess_letter(pid, "o", @number)      
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid, @number) 
        GameServer.guess_letter(pid, "y", @number)      
        assert {"_ _ _ _ ", ["o", "c", "h", "g", "r"], 5, 5, :lose} = GameServer.get_game_state(pid, @number) 
    end

    test "game over, winning state if all letters guess correctly", %{pid: pid} do
        GameServer.guess_letter(pid, "t", @number)      
        GameServer.guess_letter(pid, "e", @number)      
        GameServer.guess_letter(pid, "p", @number)      
        GameServer.guess_letter(pid, "s", @number)  
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} = GameServer.get_game_state(pid, @number) 
        GameServer.guess_letter(pid, "u", @number) 
        assert {"test", ["s", "p", "e", "t"], 1, 5, :win} =  GameServer.get_game_state(pid, @number) 
    end

end