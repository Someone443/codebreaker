require_relative './codebreaker_smn/config/setup.rb'

module CodebreakerSmn
  class Game
    include ValidationHelper

    DIFFICULTIES = {
      easy: { attempts: 15, hints: 2 },
      medium: { attempts: 10, hints: 1 },
      hell: { attempts: 5, hints: 1 }
    }.freeze

    attr_reader :code, :state, :difficulty, :username
    attr_accessor :attempts, :hints, :hint_code

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

    def win
      @state = :win
    end

    def game_over
      @state = :game_over
    end

    def high_scores
      attempts_total = DIFFICULTIES[@difficulty.to_sym][:attempts]
      attempts_used = attempts_total - @attempts
      hints_total = DIFFICULTIES[@difficulty.to_sym][:hints]
      hints_used = hints_total - @hints
      { name: @username, difficulty: @difficulty,
        attempts_total: attempts_total, attempts_used: attempts_used,
        hints_total: hints_total, hints_used: hints_used,
        date: Date.today }
    end

    def generate_code
      @code = Array.new(4) { rand(1..6) }
    end

    def generate_hint
      @hint_code = @code.sample(DIFFICULTIES[@difficulty.to_sym][:hints])
    end

    def guess_code(input)
      return unless valid_guess?(input)

      result = ''
      if @attempts > 1 && @state == :started
        @attempts -= 1
        result = CodeHandler.process_guess(@code, input)
        select_winner(result, @attempts)
      elsif @attempts == 1 && @state == :started
        @attempts -= 1
        result = CodeHandler.process_guess(@code, input)
        select_winner(result, @attempts)
      else
        game_over
      end
      result
    end

    def select_winner(result, attempts)
      if attempts.positive?
        win if result == '++++'
      else
        result == '++++' ? win : game_over
      end
    end

    def get_hint
      result = @hint_code || generate_hint
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
      return unless valid_difficulty?(level, DIFFICULTIES.keys.map(&:to_s))

      @difficulty = level
      @attempts = DIFFICULTIES[level.to_sym][:attempts]
      @hints = DIFFICULTIES[level.to_sym][:hints]
    end

    private

    attr_writer :code, :state

    def reset_params
      @username, @difficulty, @hint_code = nil
    end
  end
end
