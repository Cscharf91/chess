class Player
    attr_accessor :color, :name
    def initialize(input)
        @color = input.fetch(:color)
        @name = input.fetch(:name)
    end
end