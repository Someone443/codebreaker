require "codebreaker_smn"
require_relative './helpers/output'

class CodebreakerConsole
  include Output

  DIFFICULTIES = ['easy', 'medium', 'hell']

  attr_reader :game

  def initialize
    @game = CodebreakerSmn::Game.new
  end
  
  def init
    init_message
    loop do
      run
    end
  end

  def run
    case @game.state
    when :new then new_game
    when :started then start
    when :win
      win_message(@game.code.join)
      save_results
      new_game
    when :game_over
      game_over_message(@game.code.join)
      new_game
    end
  end

  def new_game
    @game.new_game

    welcome_message
    case gets.chomp
    when 'start' 
      @game.start
      start
    when 'rules' then rules
    when 'stats' then stats
    when 'exit' then exit_game
    else unknown_command_message
    end
  end

  def start
    registration
    if @game.username && @game.difficulty
      start_game_message
      input = gets.chomp
      case input
      when /^[1-6]{4}$/ then puts @game.guess_code(input)
      when 'hint' then puts @game.get_hint
      when 'exit' then exit_game
      else unknown_command_message
      end
    end
  end

  def registration
    unless @game.username
      set_username
    else
      set_difficulty unless @game.difficulty
    end
  end

  def set_username
    set_username_message
    input = gets.chomp

    case input
    when 'exit' then exit_game
    else
      if @game.valid_name?(input)
        @game.username = input
      else
        invalid_username_message
      end
    end
  end

  def set_difficulty
    set_difficulty_message
    level = gets.chomp

    case level
    when 'exit' then exit_game
    else
      @game.set_difficulty(level) if DIFFICULTIES.include?(level)
    end
  end

  def rules
    rules_text
  end

  def stats # This method should take stat from @results var, format it and put into console
    puts @game.high_scores
  end

  def save_results
    save_results_message
    case gets.chomp
    when /^y|yes$/
      @game.save_results
      results_saved_message
    end
  end

  def exit_game
    exit_game_message
    exit
  end
end
