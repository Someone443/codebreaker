# frozen_string_literal: true

class CodebreakerConsole
  include Validations

  attr_reader :game

  def initialize
    @game = CodebreakerSmn::Game.new
  end

  def init
    Messages.init
    loop do
      run
    end
  end

  def run
    case @game.state
    when :new then new_game
    when :started then start
    when :win
      Messages.win(@game.code.join)
      save_results
      new_game
    when :game_over
      Messages.game_over(@game.code.join)
      new_game
    end
  end

  def new_game
    @game.new_game

    Messages.welcome
    case gets.chomp
    when 'start'
      @game.start
      start
    when 'rules' then Messages.rules
    when 'stats' then Statistics.show
    when 'exit' then exit_game
    else Messages.unknown_command
    end
  end

  def start
    registration
    return unless @game.username && @game.difficulty

    Messages.start_game
    input = gets.chomp
    case input
    when /^[1-6]{4}$/ then puts @game.guess_code(input)
    when 'hint' then puts @game.get_hint
    when 'exit' then exit_game
    else Messages.unknown_command
    end
  end

  def registration
    if @game.username
      set_difficulty unless @game.difficulty
    else
      set_username
    end
  end

  def set_username
    Messages.set_username
    input = gets.chomp

    case input
    when 'exit' then exit_game
    else
      if valid_name?(input)
        @game.username = input
      else
        Messages.invalid_username
      end
    end
  end

  def set_difficulty
    Messages.set_difficulty
    level = gets.chomp

    case level
    when 'exit' then exit_game
    else @game.difficulty = level if valid_difficulty?(level, @game.class::DIFFICULTIES.keys.map(&:to_s))
    end
  end

  def save_results
    Messages.save_results
    case gets.chomp
    when /^[Yy]|[Yy]es$/
      Statistics.save(@game.high_scores)
      Messages.results_saved
    end
  end

  def exit_game
    Messages.exit_game
    exit
  end
end
