class Cell
    attr_accessor :color, :piece
    def initialize(piece = "")
        @piece = piece
        @color = nil
    end
end