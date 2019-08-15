# frozen_string_literal: true

module CodebreakerSmn
  class CodeHandler
    def self.process_guess(code, input)
      temp_code = code.clone
      input = input.split('').map(&:to_i)

      result = plus(temp_code, input) + minus(temp_code, input)

      yield(result)

      result
    end

    def self.plus(code, input)
      input.collect.with_index do |char, index|
        if code.include?(char) && (code[index] == char)
          input[index], code[index] = nil
          '+'
        end
      end.join
    end

    def self.minus(code, input)
      input.compact!
      code.compact!
      code.collect.with_index do |char, index|
        if input.include?(char)
          code[index], input[input.index(char)] = nil
          '-'
        end
      end.join
    end
  end
end
