class CurrencyConverter
  include ActionView::Helpers::NumberHelper

  CONVERSION_PREFIX = "FX rate"
  DEPRECATED_CONVERSION_PREFIXES = ["CX rate"]
  SKIP_KEYWORD = "skip"

  def initialize(transactions:, from:, to:, memo_position: "left")
    @transactions = transactions
    @from_currency = from
    @to_currency = to
    @memo_position = memo_position
  end

  def run
    @transactions.map do |transaction|
      if unconverted?(transaction) && not_skipped?(transaction) && without_subtransactions?(transaction)
        original_amount = Money.from_amount(transaction.amount/1000, @from_currency)
        transaction.amount = convert(original_amount)
        transaction.memo = update_memo(transaction.memo, original_amount)
        transaction
      end
    end.compact
  end

  private

  def unconverted?(transaction)
    supported_prefixes.none? do |prefix|
      /#{Regexp.quote(prefix)}/ =~ transaction.memo
    end
  end

  def supported_prefixes
    DEPRECATED_CONVERSION_PREFIXES + [CONVERSION_PREFIX]
  end

  def not_skipped?(transaction)
    /#{Regexp.quote(SKIP_KEYWORD)}/e !~ transaction.memo
  end

  # Uploading subtransactions is unsupported by the Ynab API
  def without_subtransactions?(transaction)
    transaction.subtransactions.blank?
  end

  def convert(amount)
    (amount.exchange_to(@to_currency) * 1000).to_i
  end

  def update_memo(old_memo, original_amount)
    conversion_text = conversion_text(original_amount, old_memo.present?)

    (old_memo || "")
      .slice(0...50-conversion_text.length)
      .send(memo_position_method_name, conversion_text)
  end

  def memo_position_method_name
    if @memo_position == "right"
      :<<
    else
      :prepend
    end
  end

  def conversion_text(original_amount, separator)
    memo = "#{original_amount.format(disambiguate: true)} (#{CONVERSION_PREFIX}: #{cx_rate}) "

    if separator
      " · ".send(memo_position_method_name, memo)
    else
      memo
    end
  end

  def cx_rate
    @cx_rate ||= number_with_precision(
      Money.default_bank.get_rate(@from_currency, @to_currency),
      precision: 5,
      significant: true,
      strip_insignificant_zeros: true
    )
  end
end
