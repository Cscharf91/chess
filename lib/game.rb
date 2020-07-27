require 'pry'
require_relative 'board'
require_relative 'save_load'
class Game
    include SaveLoad
    attr_reader :players, :board, :current_player, :other_player
    def initialize(players, board = Board.new)
        @players = players
        @board = board
        @current_player, @other_player = players.shuffle
    end

    def switch_players
        @current_player, @other_player = @other_player, @current_player
    end

    def ask_move
        "#{current_player.name}: Enter a piece to select/move (eg. a 2), or back to unselect:"
    end

    def get_move
        x, y = gets.chomp.downcase.split(" ")
        if x == "save"
            save_game(self)
            play
        elsif x == "load"
            load_game
        end
        move_to_input(x, y)
    end

    def move_to_input(x, y)
        mapping = {
            "a" => 1,
            "b" => 2,
            "c" => 3,
            "d" => 4,
            "e" => 5,
            "f" => 6,
            "g" => 7,
            "h" => 8,
            "8" => 0,
            "7" => 1,
            "6" => 2,
            "5" => 3,
            "4" => 4,
            "3" => 5,
            "2" => 6,
            "1" => 7,
            "back" => "back"
        }
        if y.nil?
            [mapping[x]]
        else
            [mapping[x], mapping[y]]
        end
    end

    def game_over_message
        return "#{current_player.name} won!" if board.game_over == :winner
        return "The game ended in a tie" if board.game_over == :draw
    end

    def is_taking_piece?(x, y)
        if board.get_cell_piece(x, y) != ""
            true
        else
            false
        end
    end

    def promote(x, y)
        puts "What would you like to promote your pawn into?"
        puts "Options: queen, rook, knight, bishop, none"
        new_piece = gets.chomp.downcase
        until new_piece == "queen" || new_piece == "rook" || new_piece == "knight" || new_piece == "bishop" || new_piece == "none"
            puts "Invalid- please enter one of the accepted options."
            puts "Options: queen, rook, knight, bishop, none"
            new_piece = gets.chomp.downcase
        end

        board.get_cell_piece(x, y).type = new_piece
    end

    def check_for_check
        p1_pieces = current_player.pieces_left
        p2_pieces = other_player.pieces_left
        p2_pieces.each do |piece, coord|
            x = coord[0]
            y = coord[1]
            next if board.get_cell_piece(x, y) == ""
            if board.get_cell_piece(x, y).type == "pawn"
                board.pawn_path(x, y)
            elsif board.get_cell_piece(x, y).type == "rook"
                board.rook_path(x, y)
            elsif board.get_cell_piece(x, y).type == "bishop"
                board.bishop_path(x, y)
            elsif board.get_cell_piece(x, y).type == "knight"
                board.knight_path(x, y)
            elsif board.get_cell_piece(x, y).type == "queen"
                board.queen_path(x, y)
            elsif board.get_cell_piece(x, y).type == "king"
                board.king_path(x, y)
                if other_player.color == "white"
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_left(x, y)
                    end 
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_right(x, y)
                    end
                elsif other_player.color == "black"
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_left(x, y)
                    end
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_right(x, y)
                    end
                end
            end
        end
        #board.get_cell_color(current_player.pieces_left("king"))
        kingx, kingy = current_player.pieces_left[:king]
        if board.get_cell_color(kingx, kingy) == "red"
            board.set_up_grid
            return true
        else
            board.set_up_grid
            return false
        end
    end

    def temp_move(x, y)
        board.grid.each_with_index do |row, idx|
            row.each_with_index do |cell, idx2|
                next if board.get_cell_piece(idx2, idx) == ""
                if idx < 8 && idx2 > 0
                    if board.get_cell_color(idx2, idx) == "red"
                        #next if is_taking_piece?(idx2, idx) == false
                        hash_value = current_player.pieces_left.key([x, y])
                        opponent_hash = other_player.pieces_left.key([idx2, idx])
                        temp_spot = {}
                        temp_spot[opponent_hash] = [idx2, idx]
                        other_player.pieces_left.delete(opponent_hash)
                        current_player.pieces_left[hash_value] = [idx2, idx]
                        board.temp_move_back(x, y, idx2, idx)
                        board.set_up_grid
                        if check_for_check == true
                            board.temp_move_back(idx2, idx, x, y)
                            hash_value = current_player.pieces_left.key([idx2, idx])
                            other_player.pieces_left[temp_spot.keys[0]] = temp_spot.values[0]
                            current_player.pieces_left[hash_value] = [x, y]
                            other_player.pieces_left[opponent_hash] = [idx2, idx]
                            true
                        else
                            board.temp_move_back(idx2, idx, x, y)
                            hash_value = current_player.pieces_left.key([idx2, idx])
                            other_player.pieces_left[temp_spot.keys[0]] = temp_spot.values[0]
                            current_player.pieces_left[hash_value] = [x, y]
                            other_player.pieces_left[opponent_hash] = [idx2, idx]
                            return false
                        end
                    end
                end
            end
        end
    end

    def check_for_checkmate
        p1_pieces = current_player.pieces_left
        p2_pieces = other_player.pieces_left
        p1_pieces.each do |piece, coord|
            x = coord[0]
            y = coord[1]
            next if board.get_cell_piece(x, y) == ""
            if board.get_cell_piece(x, y).type == "pawn"
                board.pawn_path(x, y)
                board.take_out_blanks
                return false if temp_move(x, y) == false
            elsif board.get_cell_piece(x, y).type == "rook"
                board.rook_path(x, y)
                board.take_out_blanks
                return false if temp_move(x, y) == false
            elsif board.get_cell_piece(x, y).type == "bishop"
                board.bishop_path(x, y)
                board.take_out_blanks
                return false if temp_move(x, y) == false
            elsif board.get_cell_piece(x, y).type == "knight"
                board.knight_path(x, y)
                return false if temp_move(x, y) == false
            elsif board.get_cell_piece(x, y).type == "queen"
                board.queen_path(x, y)
                board.take_out_blanks
                return false if temp_move(x, y) == false
            elsif board.get_cell_piece(x, y).type == "king"
                board.king_path(x, y)
                board.take_out_blanks
                return false if temp_move(x, y) == false
                if other_player.color == "white"
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_left(x, y)
                        board.take_out_blanks
                        return false if temp_move(x, y) == false
                    end 
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_right(x, y)
                        board.take_out_blanks
                        return false if temp_move(x, y) == false
                    end
                elsif other_player.color == "black"
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_left(x, y)
                        board.take_out_blanks
                        return false if temp_move(x, y) == false
                    end
                    if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x, y).first_move
                        board.castle_right(x, y)
                        board.take_out_blanks
                        return false if temp_move(x, y) == false
                    end
                end
            end
        end
    end
      def check_path(x, y)
        #check for en passant then select remaining pawn moves
        if board.get_cell_piece(x, y).type == "pawn"
            if current_player.color == "white" && y == 3 #and opponent pawn is next to you?
                board.en_passant_path(x, y) if other_player.en_passant
            elsif current_player.color == "black" && y == 4
                board.en_passant_path(x, y) if other_player.en_passant
            end
            board.pawn_path(x, y)
        elsif board.get_cell_piece(x, y).type == "rook"
            board.rook_path(x, y)
        elsif board.get_cell_piece(x, y).type == "bishop"
            board.bishop_path(x, y)
        elsif board.get_cell_piece(x, y).type == "knight"
            board.knight_path(x, y)
        elsif board.get_cell_piece(x, y).type == "queen"
            board.queen_path(x, y)
        elsif board.get_cell_piece(x, y).type == "king"
            board.king_path(x, y)
            if current_player.color == "white"
                if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x - 4, y).first_move
                    board.castle_left(x, y)
                end 
                if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x + 3, y).first_move
                    board.castle_right(x, y)
                end
            elsif current_player.color == "black"
                if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x - 4, y).first_move
                    board.castle_left(x, y)
                end
                if board.get_cell_piece(x, y).first_move && board.get_cell_piece(x + 3, y).first_move
                    board.castle_right(x, y)
                end
            end
        end
    end

    def prompt_selection
        puts ""
        puts ask_move
        x, y = get_move
        while board.valid_select?(x, y, current_player.color) == false
          puts "Invalid option! Try again:"
          x, y = get_move
          board.valid_select?(x, y, current_player.color)
        end
          
        check_path(x, y)
        
          board.formatted_grid
          return x, y
    end

    #begins the game, alternating turns and making sure each option is a valid choice, then displays the board
    def play
        while true
            current_player.en_passant = false
            board.formatted_grid
            if check_for_check
                if check_for_checkmate
                    puts "Checkmate!"
                else
                    puts "Check!"
                end
            end
            x, y = prompt_selection
            puts ""
            puts ask_move
            x_end, y_end = get_move
            if x_end == "back"
                board.clear_board
                play
            end
            while board.valid_place?(x_end, y_end) == false
                puts "Invalid option! Try again:"
                x_end, y_end = get_move
                board.valid_place?(x_end, y_end)
            end
            #check for en passant
            if board.get_cell_piece(x, y).type == "pawn" && y_end - y == 2
                current_player.en_passant = true
            elsif board.get_cell_piece(x, y).type == "pawn" && y - y_end == 2
                current_player.en_passant = true
            end

            #check for promotion
            if board.get_cell_piece(x, y).type == "pawn" && board.get_cell_piece(x, y).color == "white" && y_end == 0
                promote(x, y)
            elsif board.get_cell_piece(x, y).type == "pawn" && board.get_cell_piece(x, y).color == "black" && y_end == 7
                promote(x, y)
            end

            #check for castling
            if board.get_cell_piece(x, y).type == "king" && x_end - x == 2
                board.piece_move(x + 3, y, x + 1, y)
                board.set_cell_color(x + 2, y, "red")
            elsif board.get_cell_piece(x, y).type == "king" && x - x_end == 2
                board.piece_move(x - 4, y, x - 1, y)
                board.set_cell_color(x - 2, y, "red")
            end
            #check if taking an opponent's piece
            if is_taking_piece?(x_end, y_end)               
                hash_value = other_player.pieces_left.key([x_end, y_end])
                current_player.pieces_left[hash_value] = [x_end, y_end]
                other_player.pieces_left.delete(hash_value)

                board.piece_move(x, y, x_end, y_end)
            else
                hash_value = current_player.pieces_left.key([x, y])
                current_player.pieces_left[hash_value] = [x_end, y_end]
                board.piece_move(x, y, x_end, y_end)
            end
          #if board.game_over
            #puts game_over_message
            #board.formatted_grid
            #return
          #else
            switch_players
          #end
        end
    end

end