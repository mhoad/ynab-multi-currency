module Conversions
  class Initializer
    include ActionView::Helpers::NumberHelper

    CONVERSION_PREFIX = "FX rate"
    DEPRECATED_CONVERSION_PREFIXES = ["CX rate"]
    SKIP_KEYWORD = "skip"

    def initialize(conversion)
      @conversion = conversion
      @from_currency = conversion.from_currency
      @to_currency = conversion.to_currency
      @memo_position = conversion.memo_position || "left"
      @offset = conversion.offset || 1
      @custom_fx_rate = conversion.custom_fx_rate
    end

    def self.call(conversion)
      new(conversion).call
    end

    def call
      transactions = convert_transactions
      return if transactions.blank?
      @conversion.syncs.create!(transactions: transactions)
    end

    private

    def convert_transactions
      transactions_since_start_date.map do |transaction|
        if unconverted?(transaction) && not_skipped?(transaction) && without_subtransactions?(transaction)
          original_amount = Money.from_amount(transaction.amount.fdiv(1000), @from_currency) * @offset
          transaction.amount = convert(original_amount)
          transaction.memo = update_memo(transaction.memo, original_amount)
          transaction
        end
      end.compact
    end

    def transactions_since_start_date
      adapter = YnabAdapter.new(@conversion.user)
      adapter.transactions(
        since: @conversion.start_date,
        budget_id: @conversion.ynab_budget_id,
        account_id: @conversion.ynab_account_id
      )
    end

    def unconverted?(transaction)
      supported_prefixes.none? do |prefix|
        /#{Regexp.quote(prefix)}/ =~ transaction.memo
      end
    end

    def supported_prefixes
      DEPRECATED_CONVERSION_PREFIXES + [CONVERSION_PREFIX]
    end

    def not_skipped?(transaction)
      /#{Regexp.quote(SKIP_KEYWORD)}/i !~ transaction.memo
    end

    # Uploading subtransactions is unsupported by the Ynab API
    def without_subtransactions?(transaction)
      transaction.subtransactions.blank?
    end

    def convert(amount)
      (bank.exchange_with(amount, @to_currency) * 1000).to_i
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
      memo = "#{original_amount.format(disambiguate: true)} (#{CONVERSION_PREFIX}: #{cx_rate})"

      if separator
        " · ".send(memo_position_method_name, memo)
      else
        memo
      end
    end

    def cx_rate
      @cx_rate ||= number_with_precision(
        @bank.get_rate(@from_currency, @to_currency),
        precision: 5,
        significant: true,
        strip_insignificant_zeros: true
      )
    end

    def bank
      @bank ||= if @custom_fx_rate
        bank = Money::Bank::VariableExchange.new
        bank.add_rate(@from_currency, @to_currency, @custom_fx_rate)
        bank
      else
        Money.default_bank
      end
    end
  end
end
