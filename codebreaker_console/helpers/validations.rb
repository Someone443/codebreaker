# frozen_string_literal: true

module Validations
  def not_empty_string(input)
    (input.is_a? String) && !input.empty?
  end

  def valid_length(input:, from:, to:)
    input.size.between?(from, to)
  end
end
