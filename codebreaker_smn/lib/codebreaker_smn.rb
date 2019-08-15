require_relative './codebreaker_smn/config/setup.rb'

module CodebreakerSmn
  class Game
    include ValidationHelper

    DIFFICULTIES = {
      easy: { attempts: 15, hints: 2 },
      medium: { attempts: 10, hints: 1 },
      hell: { attempts: 5, hints: 1 }
    }.freeze

    CODE_RULES = {
      size: 4,
      digits: 1..6
    }.freeze

    WIN_RESULT = '++++'.freeze

    attr_reader :code, :state, :difficulty, :username
    attr_accessor :attempts, :hints

    def initialize
      new_game
    end

    def new_game
      reset_params
      @state = :new
    end

    def start
      generate_code
      @state = :started
    end

    def statistics
      attempts_total = DIFFICULTIES[@difficulty][:attempts]
      attempts_used = attempts_total - @attempts
      hints_total = DIFFICULTIES[@difficulty][:hints]
      hints_used = hints_total - @hints
      { name: @username, difficulty: @difficulty.to_s,
        attempts_total: attempts_total, attempts_used: attempts_used,
        hints_total: hints_total, hints_used: hints_used,
        date: Date.today }
    end

    def guess_code(input)
      return unless valid_guess?(input)

      CodeHandler.process_guess(@code, input) do |result|
        select_winner(result)
        take_attempt
      end
    end

    def get_hint
      result = hint_code
      if @hints.positive? && @state == :started
        @hints -= 1
        result.pop
      else
        'No hints left!'
      end
    end

    def username=(username)
      return unless valid_name?(username)

      @username = username
    end

    def difficulty=(level)
      return unless valid_difficulty?(level.to_sym, DIFFICULTIES.keys)

      @difficulty = level.to_sym
      @attempts = DIFFICULTIES[level.to_sym][:attempts]
      @hints = DIFFICULTIES[level.to_sym][:hints]
    end

    private

    attr_writer :code, :state

    def win
      @state = :win
    end

    def game_over
      @state = :game_over
    end

    def generate_code
      @code = Array.new(CODE_RULES[:size]) { rand(CODE_RULES[:digits]) }
    end

    def hint_code
      @hint_code ||= @code.sample(DIFFICULTIES[@difficulty][:hints])
    end

    def select_winner(result)
      if many_attempts?
        win if winner?(result)
      elsif last_attempt?
        winner?(result) ? win : game_over
      else
        game_over
      end
    end

    def take_attempt
      @attempts -= 1
    end

    def many_attempts?
      @attempts > 1 && @state == :started
    end

    def last_attempt?
      @attempts == 1 && @state == :started
    end

    def winner?(result)
      result == WIN_RESULT
    end

    def reset_params
      @username, @difficulty, @hint_code = nil
    end
  end
end
