# frozen_string_literal: true

class Statistics
  def self.save(data)
    DbManager.save(data)
  end

  def self.show
    statistics = sorted(DbManager.load)
    StatPresenter.new(statistics).show
  end

  def self.sorted(data)
    order = CodebreakerSmn::Game::DIFFICULTIES.keys.map(&:to_s)
    data.sort_by { |result| [order.index(result[:difficulty]), result[:attempts_used], result[:hints_used]] }
  end
end
