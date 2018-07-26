class Sync < ApplicationRecord
  serialize :transactions, Array
  belongs_to :conversion

  STALE_TIME = 1.hour.ago

  scope :confirmed, -> { where(confirmed: true).order(:created_at) }
  scope :stale, -> { where.not(transactions: nil).where("created_at < ?", STALE_TIME) }

  def confirm!
    transactions.each(&:update)
    count = transactions.count
    update(confirmed: true, transactions: nil)
    count
  end

  def self.delete_stale_transactions
    stale.update_all(transactions: nil)
  end
end
