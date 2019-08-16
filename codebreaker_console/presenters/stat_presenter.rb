# frozen_string_literal: true

class StatPresenter
  def initialize(statistics)
    @statistics = statistics
  end

  def show
    puts Terminal::Table.new(headings: headings, rows: rows)
  end

  private

  def headings
    ['#', 'Name', 'Level', 'Attempts Left', 'Hints Left', 'Date']
  end

  def rows
    @statistics.map.with_index do |result, index|
      [
        index + 1, result[:name], result[:difficulty],
        attempts_left(result), hints_left(result), result[:date]
      ]
    end
  end

  def attempts_left(result)
    "#{result[:attempts_total] - result[:attempts_used]}/#{result[:attempts_total]}"
  end

  def hints_left(result)
    "#{result[:hints_total] - result[:hints_used]}/#{result[:hints_total]}"
  end
end
