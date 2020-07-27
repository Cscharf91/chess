require_relative 'board'
require_relative 'cell'
require_relative 'core_extensions'
require_relative 'piece'
require_relative 'player'
require_relative 'game'
require_relative 'save_load'

puts "Welcome to Chess!"
puts "Player 1: White pieces"
puts "Enter your name:"
p1_name = gets.chomp
p1 = Player.new({color: "white", name: p1_name})
puts "Player 2: Black pieces"
puts "Enter your name:"
p2_name = gets.chomp
p2 = Player.new({color: "black", name: p2_name})
players = [p1, p2]
Game.new(players).play