class Sync < ApplicationRecord
  serialize :transactions
  belongs_to :conversion
end
