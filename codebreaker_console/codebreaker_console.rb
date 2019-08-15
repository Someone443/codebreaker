# frozen_string_literal: true

class CodebreakerConsole
  include Validations

  STATES = {
    new: 'new_game',
    started: 'start',
    win: 'win',
    game_over: 'game_over'
  }.freeze

  COMMANDS = {
    start: 'start',
    hint: 'hint',
    rules: 'rules',
    stats: 'stats',
    exit: 'exit',
    yes: 'yes'
  }.freeze

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
    send(STATES[@game.state])
  end

  def new_game
    @game.new_game

    Messages.welcome
    case user_input
    when COMMANDS[:start]
      @game.start
      start
    when COMMANDS[:rules] then Messages.rules
    when COMMANDS[:stats] then Statistics.show
    else Messages.unknown_command
    end
  end

  def start
    registration
    return if !(@game.username && @game.difficulty)

    Messages.start_game
    input = user_input
    case input
    when code_matcher then puts @game.guess_code(input)
    when COMMANDS[:hint] then puts @game.get_hint
    else Messages.unknown_command
    end
  end

  def win
    Messages.win(@game.code.join)
    save_results
    new_game
  end

  def game_over
    Messages.game_over(@game.code.join)
    new_game
  end

  def code_matcher
    /^[1-6]{4}$/
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
    input = user_input
    return Messages.invalid_username unless valid_name?(input)

    @game.username = input
  end

  def set_difficulty
    Messages.set_difficulty
    level = user_input
    return unless valid_difficulty?(level.to_sym, @game.class::DIFFICULTIES.keys)

    @game.difficulty = level
  end

  def save_results
    Messages.save_results
    case user_input
    when COMMANDS[:yes]
      Statistics.save(@game.high_scores)
      Messages.results_saved
    end
  end

  def user_input
    input = gets.chomp
    exit_game if input == COMMANDS[:exit]

    input
  end

  def exit_game
    Messages.exit_game
    exit
  end
end
