class Piece
    attr_accessor :color, :type, :first_move
    def initialize(color, type)
        @type = type
        @color = color
        @first_move = true
    end

    def to_s
        if color == "black"
            return "\u265a" if type == "king"
            return "\u265b" if type == "queen"
            return "\u265c" if type == "rook"
            return "\u265d" if type == "bishop"
            return "\u265e" if type == "knight"
            return "\u265f" if type == "pawn"
        else
            return "\u2654" if type == "king"
            return "\u2655" if type == "queen"
            return "\u2656" if type == "rook"
            return "\u2657" if type == "bishop"
            return "\u2658" if type == "knight"
            return "\u2659" if type == "pawn"
        end
    end

    def moves
        case type 
        when "pawn"
            pawn_moves
        when "king"
            king_moves
        else
            knight_moves
        end
    end

    def pawn_moves
        if color == "white"
            if first_move
                [
                    [0, 1], [0, 2]
                ]
            else
                [0, 1]
            end
        elsif color == "black"
            if first_move
                [
                    [0, -1], [0, -2]
                ]
            else
                [0, -1]
            end
        end
    end

    def knight_moves
        [
            [1, 2], [-1, -2], [-1, 2], [1, -2], [-2, -1], [2, 1], [-2, 1], [2, -1]
        ]
    end

    def king_moves
        [
            [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1]
        ]
    end

end

#[0] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[1] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[2] [ ] [ ] [x] [x] [ ] [ ] [ ] [ ]
#[3] [ ] [ ] [x] [*] [x] [ ] [ ] [ ]
#[4] [ ] [ ] [x] [x] [x] [ ] [ ] [ ]
#[5] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]
#[6] [p] [p] [p] [p] [p] [p] [p] [p]
#[7] [r] [h] [b] [q] [k] [b] [h] [r]
#    [1] [2] [3] [4] [5] [6] [7] [8]