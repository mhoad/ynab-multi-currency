class ExchangeRate < ApplicationRecord
  def self.get_rate(from_iso_code, to_iso_code)
    rate = find_by(from: from_iso_code, to: to_iso_code)
    rate.present? ? rate.rate : nil
  end

  def self.add_rate(from_iso_code, to_iso_code, rate)
    exrate = find_or_initialize_by(from: from_iso_code, to: to_iso_code)
    exrate.rate = rate
    exrate.save!
  end

  def self.currencies
    select(:from).distinct.order(:from).pluck(:from).map do |from|
      Money::Currency.new(from)
    end
  end
end
