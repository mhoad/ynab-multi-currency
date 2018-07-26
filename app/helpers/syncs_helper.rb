module SyncsHelper
  def format_ynab_amount(amount, currency)
    Money.new(amount / 10, currency).format(disambiguate: true)
  end
end
