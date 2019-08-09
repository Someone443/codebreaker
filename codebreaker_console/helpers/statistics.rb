class Statistics
  DB_PATH = 'db/results.yml'.freeze

  def self.load
    YAML.load_file(DB_PATH)
  rescue SystemCallError
    []
  end

  def self.save(data)
    results = self.load
    results << data

    File.write(DB_PATH, sorted(results).to_yaml)
  end

  def self.show
    headings = ['#', 'Name', 'Level', 'Attempts Left', 'Hints Left', 'Date']
    rows = self.load.map.with_index do |result, index|
      attempts_left = "#{result[:attempts_total] - result[:attempts_used]}/#{result[:attempts_total]}"
      hints_left = "#{result[:hints_total] - result[:hints_used]}/#{result[:hints_total]}"
      [index + 1, result[:name], result[:difficulty], attempts_left, hints_left, result[:date]]
    end

    puts Terminal::Table.new(headings: headings, rows: rows)
  end

  def self.sorted(data)
    order = %w[hell medium easy]
    data.sort_by { |result| [order.index(result[:difficulty]), result[:attempts_used], result[:hints_used]] }
  end
end
