class Sync < ApplicationRecord
  serialize :transactions, Array
  belongs_to :conversion

  scope :confirmed, -> { where(confirmed: true).order(:created_at) }

  def confirm!
    transactions.each(&:update)
    count = transactions.count
    update(confirmed: true, transactions: nil)
    count
  end
end
