class Conversion < ApplicationRecord
  has_many :syncs

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
    Ynaby::Account.find(budget_id: ynab_budget_id, account_id: ynab_account_id)
  end
end
