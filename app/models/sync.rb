class Sync < ApplicationRecord
  serialize :transactions, Array
  belongs_to :conversion

  scope :confirmed, -> { where(confirmed: true).order(:created_at) }

  def confirm!
    transactions.each(&:update)
    update(confirmed: true)
  end
end
