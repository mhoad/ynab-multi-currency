class Sync < ApplicationRecord
  serialize :transactions, Array
  belongs_to :add_on

  STALE_TIME = 1.hour.ago

  scope :confirmed, -> { where(confirmed: true).order(:created_at) }
  scope :stale, -> { where.not(transactions: nil).where("created_at < ?", STALE_TIME) }

  def self.delete_stale_transactions
    stale.update_all(transactions: nil)
  end
end
