require 'pry'
require_relative 'cell.rb'
require_relative 'core_extensions.rb'
require_relative 'piece.rb'
class Board
    attr_reader :grid
    def initialize(input = {})
        @grid = input.fetch(:grid, default_grid)
        starting_pieces
        set_up_grid
    end

    def get_cell(x, y)
        grid[y][x]
    end

    def get_cell_piece(x, y)
        get_cell(x, y).piece
    end

    def set_cell(x, y, value)
        get_cell(x, y).piece = value
    end

    def set_cell_plus_color(x, y, value, new_color)
        get_cell(x, y).piece = value
        get_cell(x, y).color = new_color
    end

    def get_cell_color(x, y)
        get_cell(x, y).color
    end

    def set_cell_color(x, y, value)
        get_cell(x, y).color = value
    end

    def game_over
        return :winner if winner?
        return :draw if draw?
        false
    end

    #displays the game board in the terminal - could be refactored with a cell#to_s method
    def formatted_grid
        grid.each do |row|
          puts row.map { |cell|
            if cell.piece.to_s.empty?
                if cell.color == "blue"
                    "   ".bg_blue.black
                elsif cell.color == "gray"
                    "   ".bg_gray.black
                elsif cell.color == "red"
                    "   ".bg_red.black
                elsif cell.color == "brown"
                    "   ".bg_brown.black
                else 
                    "   "
                end
            else
                if cell.color == "blue"
                    " #{cell.piece} ".bg_blue.black
                elsif cell.color == "gray"
                    " #{cell.piece} ".bg_gray.black
                elsif cell.color == "red"
                    " #{cell.piece} ".bg_red.black
                elsif cell.color == "brown"
                    " #{cell.piece} ".bg_brown.black
                else
                    cell.piece
                end
            end
        }.join("")
        end
    end

    #confirms the player's choice is valid (the column isn't full)
    def valid_select?(x, y, color)
        return false if y == nil && x != "back" && x != "save" && x != "load"
        return false if get_cell(x, y).piece == ""
        if get_cell_piece(x, y).color != color
            false
        elsif x == nil || y == nil
            false
        elsif get_cell_piece(x, y) == "" #might have to add side grid coords
            false
        else
            true
        end
    end

    def valid_place?(x, y)
        if x == nil || y == nil
            false
        else
            true
        end
    end

    #finds the proper y-axis placement for the player's turn
    def find_lowest_slot(x, y)
        new_y = 0
        until new_y > 4
            if get_cell_value(x, new_y + 1) == "X" || get_cell_value(x, new_y + 1) == "O"
                return new_y
            else
                new_y += 1
            end
        end
        return new_y
    end

    def piece_move(x, y, x_end, y_end)
        start = get_cell(x, y)
        if get_cell_color(x_end, y_end) == "red"
            set_cell(x_end, y_end, start.piece)
            start.piece = ""
            get_cell_piece(x_end, y_end).first_move = false
            clear_board
        else puts "Invalid move!"
        end
    end

    def temp_move_back(x, y, x_end, y_end)
        start = get_cell(x, y).piece
        finish = get_cell(x_end, y_end).piece
        set_cell(x_end, y_end, start)
        set_cell(x, y, finish)
        #start.piece = finish
        get_cell_piece(x_end, y_end).first_move = false
    end

    def clear_board
        set_up_grid
    end

    def take_out_blanks
        grid.each do |row|
            row.each do |cell|
                if cell.color == "red"
                    if cell.piece == ""
                        cell.color = "blue"
                    end
                end
            end
        end
    end

    #highlights each of the pawn's potential moves in red
    def pawn_path(x, y)
        pawn_take_piece(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        moves = start_coords.piece.moves
        if moves.include?([0,2]) || moves.include?([0,-2])
            moves.each do |move|
                new_coord = y
                finish_coord = move[1]
                i = 0
                until i == finish_coord
                    if start_coords.piece.color == "white"
                        i += 1
                        new_coord -= 1
                    else new_coord += 1
                        i -= 1
                    end
                    if get_cell(x, new_coord).piece == ""
                        set_cell_color(x, new_coord, "red")
                    else
                        return
                    end
                end
            end
        else
            new_coord = y
            if start_coords.piece.color == "white"
                new_coord -= 1
            else new_coord += 1
            end
            if get_cell(x, new_coord).piece == ""
                set_cell_color(x, new_coord, "red")
            else
                return
            end
        end
    end

    def pawn_take_piece(x, y)
        start_coords = get_cell(x, y)
        unless x - 1 == 0
            if start_coords.piece.color == "white"
                if get_cell_piece(x - 1, y - 1) != "" && get_cell_piece(x - 1, y - 1).color == "black"
                    set_cell_color(x - 1, y - 1, "red")
                end
            elsif start_coords.piece.color == "black" && y + 1 < 8
                if get_cell_piece(x - 1, y + 1) != "" && get_cell_piece(x - 1, y + 1).color == "white"
                    set_cell_color(x - 1, y + 1, "red")
                end
            end
        end
        unless x + 1 == 9
            if start_coords.piece.color == "white"
                if y + 1 < 8 && get_cell_piece(x + 1, y - 1) != "" && get_cell_piece(x + 1, y - 1).color == "black"
                    set_cell_color(x + 1, y - 1, "red")
                end
            elsif start_coords.piece.color == "black" && y + 1 < 8
                if get_cell_piece(x + 1, y + 1) != "" && get_cell_piece(x + 1, y + 1).color == "white"
                    set_cell_color(x + 1, y + 1, "red")
                end
            end
        end
    end

    def en_passant_path(x, y)
        start_coords = get_cell(x, y)
        if start_coords.piece.color == "white"
            unless x - 1 == 0 || get_cell(x - 1, y).piece == ""
                if get_cell(x - 1, y).piece.type == "pawn"
                    set_cell_color(x - 1, y - 1, "red")
                end
            end
            unless x + 1 == 9 || get_cell(x + 1, y).piece == ""
                if get_cell(x + 1, y).piece.type == "pawn"
                    set_cell_color(x + 1, y - 1, "red")
                end
            end
        elsif start_coords.piece.color == "black"
            unless x - 1 == 0 || get_cell(x - 1, y).piece == ""
                if get_cell(x - 1, y).piece.type == "pawn"
                    set_cell_color(x - 1, y + 1, "red")
                end
            end
            unless x + 1 == 9 || get_cell(x + 1, y).piece == ""
                if get_cell(x + 1, y).piece.type == "pawn"
                    set_cell_color(x + 1, y + 1, "red")
                end
            end
        end
    end

    #highlights each of the knight's potential moves in red
    def knight_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        moves = start_coords.piece.moves
        moves.each do |move|
            new_x = x + move[0]
            new_y = y + move[1]
            if new_x >= 1 && new_x <= 8 && new_y <= 7 && new_y >= 0
                if get_cell_piece(new_x, new_y) == "" || get_cell_piece(new_x, new_y).color != start_coords.piece.color
                    set_cell_color(new_x, new_y, "red")
                end
            end
        end
    end

    #highlights each of the king's potential moves in red
    def king_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        moves = start_coords.piece.moves
        moves.each do |move|
            new_x = x + move[0]
            new_y = y + move[1]
            if new_x >= 1 && new_x <= 8 && new_y <= 7 && new_y >= 0
                if get_cell_piece(new_x, new_y) == ""
                    set_cell_color(new_x, new_y, "red")
                elsif get_cell_piece(new_x, new_y).color != start_coords.piece.color
                    set_cell_color(new_x, new_y, "red")
                    return
                end
            end
        end
    end

    def castle_left(x, y)
        if get_cell_piece(x - 3, y) == "" && get_cell_piece(x - 2, y) == "" && get_cell_piece(x - 1, y) == ""
            set_cell_color(x - 2, y, "red")
        end

    end

    def castle_right(x, y)
        if get_cell_piece(x + 2, y) == "" && get_cell_piece(x + 1, y) == ""
            set_cell_color(x + 2, y, "red")
        end
    end

    #highlights each of the rook's potential moves in red
    def rook_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        horizontal_path_left(x, y)
        horizontal_path_right(x, y)
        vertical_path_down(x, y)
        vertical_path_up(x, y)
    end

    #highlights bishop path
    def bishop_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        diagonal_path_upleft(x, y)
        diagonal_path_upright(x, y)
        diagonal_path_downright(x, y)
        diagonal_path_downleft(x, y)
    end

    #highlights queen path
    def queen_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        horizontal_path_left(x, y)
        horizontal_path_right(x, y)
        vertical_path_down(x, y)
        vertical_path_up(x, y)
        diagonal_path_upleft(x, y)
        diagonal_path_upright(x, y)
        diagonal_path_downright(x, y)
        diagonal_path_downleft(x, y)
    end

    #highlights specifically vertical spots up and down from start point
    def vertical_path_down(x, y)
        start_coords = get_cell(x, y)
        new_y = y
        until new_y == 7
            new_y += 1
            if get_cell_piece(x, new_y) == ""
                set_cell_color(x, new_y, "red")
            elsif get_cell_piece(x, new_y).color != start_coords.piece.color
                set_cell_color(x, new_y, "red")
                return
            else
                return
            end
        end
    end

    def vertical_path_up(x, y)
        start_coords = get_cell(x, y)
        new_y = y
        until new_y == 0
            new_y -= 1
            if get_cell_piece(x, new_y) == ""
                set_cell_color(x, new_y, "red")
            elsif get_cell_piece(x, new_y).color != start_coords.piece.color
                set_cell_color(x, new_y, "red")
                return
            else
                return
            end
        end
    end

    #highlights specifically horizontal spots up and down from start point
    def horizontal_path_right(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        until new_x == 8
            new_x += 1
            if get_cell_piece(new_x, y) == ""
                set_cell_color(new_x, y, "red")
            elsif get_cell_piece(new_x, y).color != start_coords.piece.color
                set_cell_color(new_x, y, "red")
                return
            else
                return
            end
        end
    end

    def horizontal_path_left(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        until new_x == 1
            new_x -= 1
            if get_cell_piece(new_x, y) == ""
                set_cell_color(new_x, y, "red")
            elsif get_cell_piece(new_x, y).color != start_coords.piece.color
                set_cell_color(new_x, y, "red")
                return
            else
                return
            end
        end
    end

    #highlights specifically diagonals from start point
    def diagonal_path_upleft(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        new_y = y
        until new_x == 1 && new_y == 0
            new_x -= 1
            new_y -= 1
            return if new_x < 1 || new_y < 0
            if get_cell_piece(new_x, new_y) == ""
                set_cell_color(new_x, new_y, "red")
            elsif get_cell_piece(new_x, new_y).color != start_coords.piece.color
                set_cell_color(new_x, new_y, "red")
                return
            else
                return
            end
        end
    end

    def diagonal_path_upright(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        new_y = y
        until new_x == 8 && new_y == 0
            new_x += 1
            new_y -= 1
            return if new_x > 8 || new_y < 0
            if get_cell_piece(new_x, new_y) == ""
                set_cell_color(new_x, new_y, "red")
            elsif get_cell_piece(new_x, new_y).color != start_coords.piece.color
                set_cell_color(new_x, new_y, "red")
                return
            else
                return
            end
        end
    end

    def diagonal_path_downright(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        new_y = y
        until new_x == 8 && new_y == 7
            new_x += 1
            new_y += 1
            return if new_x > 8 || new_y > 7
            if get_cell_piece(new_x, new_y) == ""
                set_cell_color(new_x, new_y, "red")
            elsif get_cell_piece(new_x, new_y).color != start_coords.piece.color
                set_cell_color(new_x, new_y, "red")
                return
            else
                return
            end
        end
    end

    def diagonal_path_downleft(x, y)
        start_coords = get_cell(x, y)
        new_x = x
        new_y = y
        until new_x == 1 && new_y == 7
            new_x -= 1
            new_y += 1
            return if new_x < 1 || new_y > 7
            if get_cell_piece(new_x, new_y) == ""
                set_cell_color(new_x, new_y, "red")
            elsif get_cell_piece(new_x, new_y).color != start_coords.piece.color
                set_cell_color(new_x, new_y, "red")
                return
            else
                return
            end
        end
    end


    #creates a default 9x9 grid (1x1 is for the a-h/1-8 grid)
    def default_grid
        Array.new(9) { Array.new(9) { Cell.new } }
    end

    def set_up_grid
        set_grid_colors
        set_cell_plus_color(0, 0, " 8 ", nil)
        set_cell_plus_color(0, 1, " 7 ", nil)
        set_cell_plus_color(0, 2, " 6 ", nil)
        set_cell_plus_color(0, 3, " 5 ", nil)
        set_cell_plus_color(0, 4, " 4 ", nil)
        set_cell_plus_color(0, 5, " 3 ", nil)
        set_cell_plus_color(0, 6, " 2 ", nil)
        set_cell_plus_color(0, 7, " 1 ", nil)
        set_cell_plus_color(0, 8, "   ", nil)
        set_cell_plus_color(1, 8, " a ", nil)
        set_cell_plus_color(2, 8, " b ", nil)
        set_cell_plus_color(3, 8, " c ", nil)
        set_cell_plus_color(4, 8, " d ", nil)
        set_cell_plus_color(5, 8, " e ", nil)
        set_cell_plus_color(6, 8, " f ", nil)
        set_cell_plus_color(7, 8, " g ", nil)
        set_cell_plus_color(8, 8, " h ", nil)
    end

    def starting_pieces
        #pawns
        set_cell(1, 6, Piece.new("white", "pawn"))
        set_cell(2, 6, Piece.new("white", "pawn"))
        set_cell(3, 6, Piece.new("white", "pawn"))
        set_cell(4, 6, Piece.new("white", "pawn"))
        set_cell(5, 6, Piece.new("white", "pawn"))
        set_cell(6, 6, Piece.new("white", "pawn"))
        set_cell(7, 6, Piece.new("white", "pawn"))
        set_cell(8, 6, Piece.new("white", "pawn"))

        set_cell(1, 1, Piece.new("black", "pawn"))
        set_cell(2, 1, Piece.new("black", "pawn"))
        set_cell(3, 1, Piece.new("black", "pawn"))
        set_cell(4, 1, Piece.new("black", "pawn"))
        set_cell(5, 1, Piece.new("black", "pawn"))
        set_cell(6, 1, Piece.new("black", "pawn"))
        set_cell(7, 1, Piece.new("black", "pawn"))
        set_cell(8, 1, Piece.new("black", "pawn"))

        #rooks
        set_cell(1, 7, Piece.new("white", "rook"))
        set_cell(8, 7, Piece.new("white", "rook"))
        
        set_cell(1, 0, Piece.new("black", "rook"))
        set_cell(8, 0, Piece.new("black", "rook"))

        #knights
        set_cell(2, 7, Piece.new("white", "knight"))
        set_cell(7, 7, Piece.new("white", "knight"))

        set_cell(2, 0, Piece.new("black", "knight"))
        set_cell(7, 0, Piece.new("black", "knight"))
        
        #bishops
        set_cell(3, 7, Piece.new("white", "bishop"))
        set_cell(6, 7, Piece.new("white", "bishop"))

        set_cell(3, 0, Piece.new("black", "bishop"))
        set_cell(6, 0, Piece.new("black", "bishop"))
        #queens
        set_cell(4, 7, Piece.new("white", "queen"))

        set_cell(4, 0, Piece.new("black", "queen"))

        #kings
        set_cell(5, 7, Piece.new("white", "king"))

        set_cell(5, 0, Piece.new("black", "king"))
    end

    def set_grid_colors
        i = 1
        grid.each do |row|
            row.map do |cell|
                cell.color = "blue" if i.even?
                cell.color = "gray" if i.odd?
                i += 1
            end
        end
    end
end