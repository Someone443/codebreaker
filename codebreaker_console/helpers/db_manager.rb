# frozen_string_literal: true

class DbManager
  DB_PATH = 'db/results.yml'

  def self.load
    YAML.load_file(DB_PATH)
  rescue SystemCallError
    []
  end

  def self.save(data)
    results = self.load
    results << data

    File.write(DB_PATH, results.to_yaml)
  end
end
