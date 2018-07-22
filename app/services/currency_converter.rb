class CurrencyConverter
  CONVERSION_PREFIX = "CX rate"

  def initialize(transactions:, from:, to:)
    @transactions = transactions
    @from_currency = from
    @to_currency = to
  end

  def run
    @transactions.map do |transaction|
      if !already_converted?(transaction)
        original_amount = Money.new(transaction.amount/10, @from_currency)
        transaction.amount = convert(original_amount)
        transaction.memo = update_memo(transaction.memo, original_amount)
        transaction
      end
    end.compact
  end

  private

  def already_converted?(transaction)
    /#{Regexp.quote(CONVERSION_PREFIX)}/ === transaction.memo
  end

  def convert(amount)
    (amount.exchange_to(@to_currency) * 1000).to_i
  end

  def update_memo(old_memo, original_amount)
    (old_memo || "").prepend("#{@from_currency} #{original_amount} (#{CONVERSION_PREFIX}: #{cx_rate}) ")
  end

  def cx_rate
    Money.default_bank.get_rate(@from_currency, @to_currency).to_f
  end
end
