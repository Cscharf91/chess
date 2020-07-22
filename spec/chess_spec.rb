require "spec_helper"

describe Board do
    it "checks that the grid letters and numbers are present" do
        test_grid = [
            ["8", "", "", "", "", "", "", "", ""],
            ["7", "", "", "", "", "", "", "", ""],
            ["6", "", "", "", "", "", "", "", ""],
            ["5", "", "", "", "", "", "", "", ""],
            ["4", "", "", "", "", "", "", "", ""],
            ["3", "", "", "", "", "", "", "", ""],
            ["2", "", "", "", "", "", "", "", ""],
            ["1", "", "", "", "", "", "", "", ""],
            [" ", "a", "b", "c", "d", "e", "f", "g", "h"],
        ]
        board = Board.new(grid: grid)
        expect(board.formatted_grid).to eq test_grid
    end
end