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
    def valid?(x)
        new_y = 0
        until new_y > 4
            return false if new_y == 0 && (get_cell_value(x, new_y) == "X" || get_cell_value(x, new_y) == "O")
            if get_cell_value(x, new_y + 1) == "X" || get_cell_value(x, new_y + 1) == "O"
                return true
            else
                new_y += 1
            end
        end
        return true
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

    def piece_move(start, x, y)
        if get_cell_color(x, y) == "red"
            set_cell(x, y, start.piece)
            start.piece = ""
            get_cell_piece(x, y).first_move = false
            set_up_grid
            formatted_grid
        else puts "Invalid move!"
        end
    end

    #highlights each of the pawn's potential moves in red
    def pawn_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        moves = start_coords.piece.moves
        if moves.include?([0,2])
            moves.each do |move|
                puts "move 1: #{move}"
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
                        puts "empty piece?"
                        set_cell_color(x, new_coord, "red")
                        puts get_cell_color(x, new_coord)
                    else
                        puts "no empty piece?"
                        return formatted_grid
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
                puts "empty piece?"
                set_cell_color(x, new_coord, "red")
                puts get_cell_color(x, new_coord)
            else
                puts "no empty piece?"
                return formatted_grid
            end
        end
        formatted_grid
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
        formatted_grid
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
                if get_cell_piece(x, new_y) == ""
                    set_cell_color(x, new_y, "red")
                elsif get_cell_piece(x, new_y).color != start_coords.piece.color
                    set_cell_color(x, new_y, "red")
                    return formatted_grid
                end
            end
        end
        formatted_grid
    end

    #highlights each of the rook's potential moves in red
    def rook_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        horizontal_path_left(x, y)
        horizontal_path_right(x, y)
        vertical_path_down(x, y)
        vertical_path_up(x, y)
        formatted_grid
    end

    #highlights bishop path
    def bishop_path(x, y)
        start_coords = get_cell(x, y)
        start_coords.color = "brown"
        diagonal_path_upleft(x, y)
        diagonal_path_upright(x, y)
        diagonal_path_downright(x, y)
        diagonal_path_downleft(x, y)
        formatted_grid
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
        formatted_grid
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

    private

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

#testing stuff
board = Board.new
board.formatted_grid
start = board.get_cell(1, 6)
finish = board.get_cell(1, 4)
board.pawn_path(1, 6)
board.piece_move(board.get_cell(1, 6), 1, 4)
board.pawn_path(5, 6)
board.piece_move(board.get_cell(5, 6), 5, 4)
board.pawn_path(1, 4)
board.piece_move(board.get_cell(1, 4), 1, 3)
#board.knight_path(2, 7)
#board.piece_move(board.get_cell(2,7), 1, 5)
#board.knight_path(1, 5)
#board.king_path(5, 7)
board.rook_path(1, 7)
board.piece_move(board.get_cell(1,7), 1, 5)
board.rook_path(1, 5)
board.piece_move(board.get_cell(1,5), 4, 5)
board.rook_path(4, 5)
binding.pry

#[0] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[1] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[2] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[3] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[4] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[5] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[6] [p] [p] [p] [p] [p] [p] [p] [p]
#[7] [r] [h] [b] [q] [k] [b] [h] [r]
#    [1] [2] [3] [4] [5] [6] [7] [8]