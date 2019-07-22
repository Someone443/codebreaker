require_relative './codebreaker_smn/version.rb'
require_relative './codebreaker_smn/helpers/validation_helper.rb'
require_relative './codebreaker_smn/helpers/errors/validation_error.rb'
require 'yaml'

module CodebreakerSmn
  class Game
    include ValidationHelper
    # Codebreaker class
    # Codemaker class
    # DB Helper class/module
    # Stats class
    # Output class -> logic regarding returning messages on errors/hints/help/etc.
    # Validation class
    # Custom errors class    

    DIFFICULTIES = {
                   easy: {attempts: 15, hints: 2}, 
                   medium: {attempts: 10, hints: 1},
                   hell: {attempts: 5, hints: 1}  
                 }

    attr_reader :code, :state, :difficulty
    attr_accessor :username, :attempts, :hints, :results

    def initialize
      new_game
      @results = load_results
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

    def load_results # TODO!!!!   db path should be provided from Console 
      YAML.load_file('./db/results.yml')
        rescue SystemCallError
      []
    end

    def save_results # TODO!!!!
      if @state == :win

        attempts_total = DIFFICULTIES[@difficulty.to_sym][:attempts]
        attempts_used = attempts_total - @attempts
        hints_total = DIFFICULTIES[@difficulty.to_sym][:hints]
        hints_used = hints_total - @hints

        @results << {name: @username,
                   difficulty: @difficulty, 
                   attempts_total: attempts_total,
                   attempts_used: attempts_used,
                   hints_total: hints_total,
                   hints_used: hints_used,
                   date: Date.today}

        File.write('./db/results.yml', @results.to_yaml)
      end
    end

    def high_scores # TODO!!!!
      attempts_total = DIFFICULTIES[@difficulty.to_sym][:attempts]
      attempts_used = attempts_total - @attempts
      hints_total = DIFFICULTIES[@difficulty.to_sym][:hints]
      hints_used = hints_total - @hints

      { name: @username,
        difficulty: @difficulty, 
        attempts_total: attempts_total,
        attempts_used: attempts_used,
        hints_total: hints_total,
        hints_used: hints_used,
        date: Date.today }

      # This method should combine and sort stat inside @results var and just return this @results var 
      # We should return @results from just last game -> Console or Web app should form Stat on its own
      #puts 'Name, Difficulty, Attempts Total, Attempts Used, Hints Total, Hints Used'
      #@results.each do |result|  
      #  puts %Q(#{result[:name]} #{result[:difficulty]} #{result[:attempts_total].to_s} #{result[:attempts_used].to_s} #{result[:hints_total].to_s} #{result[:hints_used].to_s})
      #end
    end

    def generate_code
      @code = Array.new(4) { rand(1..6) }
    end

    def guess_code(input)
      validate_guess(input)
      result = ""
      if @attempts > 1 && @state == :started
        @attempts -= 1
        result = process_guess(input)
        win if result == "++++"
      elsif @attempts == 1 && @state == :started
        @attempts -= 1
        result = process_guess(input)
        result == "++++" ? win : game_over
      else
        game_over
      end
      result
    end

    def process_guess(input)
      temp_code = @code.clone
      input = input.split("")
      result = ""
      exclude_indexes = []
      input.each_with_index do |char, index|
        if temp_code.include?(char.to_i) && (temp_code[index] == char.to_i)
          result << "+"
          exclude_indexes << index
        end
      end

      exclude_indexes.reverse_each do |index|
        input.delete_at(index)
        temp_code.delete_at(index)
      end

      temp_code.each_with_index do |char, index|  
        if input.include?(char.to_s) # input.uniq.include? or temp_code.uniq.include?
          result << "-"
          temp_code[index] = nil # We have to check if char is one in the input or several -> count of matches in input
        end                      # code = 1455, input = 5133
      end

      result
    end

    def get_hint # TODO!
      if @hints > 0 && @state == :started
        @hints -= 1
        code.sample
      else
        'No hints left!'
      end
    end

    def set_difficulty(level)
        @difficulty = level
        @attempts = DIFFICULTIES[level.to_sym][:attempts]
        @hints = DIFFICULTIES[level.to_sym][:hints]
    end

    private

    attr_writer :code, :state, :difficulty

    def reset_params
      @username, @difficulty = nil
    end
  end
end
