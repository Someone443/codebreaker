# frozen_string_literal: true

# Validate parameters
module ValidationHelper

  def valid_name?(username)
    not_empty_string(username) && valid_username_length(username)
  end

  def validate_guess(input)

    input.split("").each { |char| positive_integer(char.to_i) }

    valid_guess_length(input)
    valid_digits(input)
  end
  
  def not_empty_string(input)
    (input.is_a? String) && !(input.empty?)
  end

  def valid_username_length(username)
    username.size.between?(3, 20)
  end

  def positive_integer(input)
    raise ValidationError unless (input.is_a? Integer) && (input.positive?)
  end

  def valid_guess_length(input)
    raise ValidationError if !(input.size.eql?(4))
  end

  def valid_digits(input)
    raise ValidationError if !(input.match(/[1-6]+/))
  end
end 
