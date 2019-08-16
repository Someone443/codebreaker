# frozen_string_literal: true

# Validate parameters
module CodebreakerSmn
  module ValidationHelper
    def not_empty_string(input)
      (input.is_a? String) && !input.empty?
    end

    def valid_length(input:, from:, to:)
      input.size.between?(from, to)
    end

    def positive_integers(input)
      input.all? { |char| positive_integer(char) }
    end

    def positive_integer(input)
      (input.is_a? Integer) && input.positive?
    end

    def valid_digits(input, range)
      input.all? { |digit| valid_digit(digit, range) }
    end

    def valid_digit(digit, range)
      range.include?(digit)
    end
  end
end
