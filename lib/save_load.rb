require 'yaml'

module SaveLoad
  def save_game(current_game)
    filename = get_name
    return false unless filename

    dump = YAML.dump(current_game)
    File.open(File.join(Dir.pwd, "/saved/#{filename}.yaml"), 'w') { |file| file.write dump }
  end

  def get_name
    begin
      filenames = Dir.glob('saved/*').map { |file| file[(file.index('/') + 1)...(file.index('.'))] }
      puts 'Enter name for saved game'
      filename = gets.chomp
      puts "#{filename} already exists." if filenames.include?(filename)

      filename
    rescue StandardError => e
      puts "#{e} Are you sure you want to rewrite the file? (Yes/No)"
      answer = gets[0].downcase
      until %w[y n].include? answer
        puts "Invalid input. #{e} Are you sure you want to rewrite the file? (Yes/No)"
        answer = gets[0].downcase
      end
      return filename if answer == 'y'

      puts 'Do you want to try again? (Yes/No)'
      answer = gets[0].downcase
      retry if answer == 'y'
    end
  end

  def load_game
    filename = choose_game
    return unless filename

    saved = File.open(File.join(Dir.pwd, filename), 'r')
    loaded_game = YAML.load(saved)
    loaded_game.play
  end

  def choose_game
    puts "Select which saved file to load: "
    filenames = Dir.glob('saved/*').map.with_index do |file, index|
      "#{index + 1}) #{file[(file.index('/') + 1)...(file.index('.'))]}"
    end
    puts filenames
    puts
    begin
      input = gets.chomp
      filename = filenames.find { |f| f.match?(/^#{Regexp.quote(input)}/) }.dup
      puts "#{input} does not exist." unless filename
      filename.slice!(/\d\) /)
      puts "#{filename} loaded..."
      puts
      "/saved/#{filename}.yaml"
    end
  end
end