module Mastermind
  DEBUG = false

  class Game
    def initialize(player, computer)
      @secret_code = Array.new(4)
      @board = [Array.new(4), Array.new(4)]
      @turn_number = 0
      @player = player.new(self)
      @computer = computer.new(self)
    end
    attr_accessor :board, :turn_number, :secret_code

    def play
      @computer.create_secret_code!
      while @turn_number < 10
        update_turn!
        puts "\n------>>> TURN #{@turn_number} <<<------".pink
        place_player_pawn(@player)
        update_result!
        if player_wins?(@player)
          puts "#{@player} win!"
          print_board
          return
        elsif @turn_number < 11
          print_board
          puts "\nTry again!"
          puts @board[0][0] if DEBUG == true
          puts @board[1][1] if DEBUG == true
        end
        print @board if DEBUG == true
      end
      puts 'You used all 10 turns. Game over.'
      nil
    end

    def place_player_pawn(player)
      a = 0
      @board[0].each do |position|
        @board[0][a] = @player.select_position!("#{a + 1}")
        a += 1
      end
    end

    def update_turn!
      @turn_number += 1
    end

    def print_board
      input_row_positions = [0, 1, 2, 3]
      result_row_positions = [[0, 1], [2, 3]]
      input_label_for_position = ->(position) { @board[0][position] || position }
      input_for_display = input_row_positions.map(&input_label_for_position).join(' ')
      result_label_for_position = ->(position) { @board[1][position] || position }
      result_row_for_display = ->(row) { row.map(&result_label_for_position).join }
      result_for_display = result_row_positions.map(&result_row_for_display).join("\n")
      joint_row = [input_for_display, result_for_display]
      puts joint_row.join("\n\n")
    end

    def player_wins?(player)
      @board[1].all? { |pawn| pawn == ' * '.green }
    end

    def update_result!
      i = 0
      @board[0].each do |p|
        if @secret_code.include?(p) && @secret_code[i] == @board[0][i]
          puts 'first' if DEBUG == true
          @board[1][i] = @player.pawn.green
        elsif @secret_code.include?(p) && @secret_code[i] != @board[0][i]
          puts 'second' if DEBUG == true
          @board[1][i] = @player.pawn.light_blue
        else
          puts 'thrd' if DEBUG == true
          @board[1][i] = " #{i} "
        end
        i += 1
      end
    end
  end

  class Player
    def initialize(game)
      @game = game
      @pawn = ' * '
    end

    attr_reader :pawn
  end

  class HumanPlayer < Player
    def select_position!(pos)
      loop do
        print "\nWhich color do you choose for position #{pos}:\n\n#{'1 = RED'.red}\n#{'2 = BLUE'.blue}\n#{'3 = YELLOW'.yellow}\n#{'4 = PINK'.pink}\n\n"
        selection = gets.to_i
        case selection
        when 1
          marker = @pawn.red
          puts marker if DEBUG == true
          return marker
        when 2
          marker = @pawn.blue
          puts marker if DEBUG == true
          return marker
        when 3
          marker = @pawn.yellow
          puts marker if DEBUG == true
          return marker
        when 4
          marker = @pawn.pink
          puts marker if DEBUG == true
          return marker
        else
          puts "You need to select a number corresponding with color.\n\n"
        end
      end
    end

    def to_s
      'You'
    end
  end

  class Computer < Player
    def create_secret_code!
      options = [@pawn.red, @pawn.blue, @pawn.yellow, @pawn.pink]
      @game.secret_code = [options.sample, options.sample, options.sample, options.sample]
      puts @game.secret_code if DEBUG == true
    end
  end
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

include Mastermind

Game.new(HumanPlayer, Computer).play
