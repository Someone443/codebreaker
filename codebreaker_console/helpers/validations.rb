module Validations
  def valid_name?(username)
    not_empty_string(username) && valid_username_length(username)
  end

  def valid_difficulty?(level, difficulty_array)
    difficulty_array.include?(level)
  end

  def not_empty_string(input)
    (input.is_a? String) && !input.empty?
  end

  def valid_username_length(input)
    input.size.between?(3, 20)
  end
end
