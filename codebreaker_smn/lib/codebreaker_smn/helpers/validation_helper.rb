# frozen_string_literal: true

# Validate parameters
module CodebreakerSmn
  module ValidationHelper
    def valid_name?(username)
      not_empty_string(username) && valid_username_length(username)
    end

    def valid_difficulty?(level, difficulty_array)
      difficulty_array.include?(level)
    end

    def valid_guess?(input)
      positive_integers(input) && valid_guess_length(input) && valid_digits(input)
    end

    def not_empty_string(input)
      (input.is_a? String) && !input.empty?
    end

    def valid_username_length(username)
      username.size.between?(3, 20)
    end

    def positive_integers(input)
      not_empty_string(input) && input.split('').all? { |char| positive_integer(char.to_i) }
    end

    def positive_integer(input)
      (input.is_a? Integer) && input.positive?
    end

    def valid_guess_length(input)
      input.size.eql?(4)
    end

    def valid_digits(input)
      input.match(/[1-6]+/)
    end
  end
end
