class Conversion < ApplicationRecord
  has_many :syncs
  belongs_to :user

  scope :active, -> { where(deleted_at: nil) }

  validates :ynab_budget_id, presence: true
  validates :ynab_account_id, presence: true
  validates :cached_ynab_account_name, presence: true
  validates :cached_ynab_budget_name, presence: true

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

  validates :user, presence: true
  validate :distinct_currencies

  def create_draft_sync(since)
    transactions = CurrencyConverter.new(
      transactions: ynab_account.transactions(since: since),
      from: from_currency,
      to: to_currency
    ).run

    syncs.create(transactions: transactions)
  end

  def last_synced_at
    syncs.confirmed.last&.created_at
  end

  private

  def ynab_account
    user.ynab_user.budget(ynab_budget_id).account(ynab_account_id)
  end

  def distinct_currencies
    if from_currency == to_currency
      errors.add(:from_currency, "has to be different from the target currency")
    end
  end
end
