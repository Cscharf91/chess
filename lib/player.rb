class Player
    attr_accessor :color, :name, :pieces_left, :taken_pieces, :en_passant
    def initialize(input)
        @color = input.fetch(:color)
        @name = input.fetch(:name)
        @taken_pieces = []
        @en_passant = false
        @pieces_left = start_pieces
    end

    def start_pieces
        if color == "white"
            {
                pawn1: [1, 6],
                pawn2: [2, 6],
                pawn3: [3, 6],
                pawn4: [4, 6],
                pawn5: [5, 6],
                pawn6: [6, 6],
                pawn7: [7, 6],
                pawn8: [8, 6],
                rook1: [1, 7],
                rook2: [8, 7],
                knight1: [2, 7],
                knight2: [7, 7],
                bishop1: [3, 7],
                bishop2: [6, 7],
                queen: [4, 7],
                king: [5, 7]
            }

        elsif color == "black"
            {
                pawn1: [1, 1],
                pawn2: [2, 1],
                pawn3: [3, 1],
                pawn4: [4, 1],
                pawn5: [5, 1],
                pawn6: [6, 1],
                pawn7: [7, 1],
                pawn8: [8, 1],
                rook1: [1, 0],
                rook2: [8, 0],
                knight1: [2, 0],
                knight2: [7, 0],
                bishop1: [3, 0],
                bishop2: [6, 0],
                queen: [4, 0],
                king: [5, 0]
            }
        end
    end
end