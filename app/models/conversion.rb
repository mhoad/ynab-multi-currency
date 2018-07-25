class Conversion < ApplicationRecord
  has_many :syncs
  belongs_to :user

  scope :active, -> { where(deleted_at: nil) }

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
end
