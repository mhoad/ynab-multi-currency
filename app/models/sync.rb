class Sync < ApplicationRecord
  serialize :transactions
  belongs_to :conversion

  scope :confirmed, -> { where(confirmed: true).order(:created_at) }
end
