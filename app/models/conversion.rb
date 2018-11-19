class Conversion < AddOn
  validates :from_currency, presence: true,
                            inclusion: {
                              in: ExchangeRate.currency_codes,
                              message: '"%{value}" is not a supported currency'
                            }

  validates :to_currency, presence: true,
                            inclusion: {
                              in: ExchangeRate.currency_codes,
                              message: '"%{value}" is not a supported currency'
                            }

  validate :distinct_currencies
  validate :base_ten_offset

  enum memo_position: [:left, :right], _suffix: true

  def create_draft_sync
    syncs.create(transactions: pending_transactions)
  end

  def transactions_since_start_date
    ynab_account.transactions(since: start_date)
  end

  private

  def pending_transactions
    CurrencyConverter.new(self).run
  end

  def distinct_currencies
    if from_currency == to_currency
      errors.add(:from_currency, "has to be different from the target currency")
    end
  end

  def base_ten_offset
    if offset && (exponent = Math.log10(offset)) != exponent.round
      errors.add(:offset, "has to be base 10 (0.001, 0.1, 1, 10, 100, etc.)")
    end
  end
end
