module ConversionsHelper
  def from_to_currencies(conversion)
    from = Money::Currency.new(conversion.from_currency)
    to = Money::Currency.new(conversion.to_currency)

    "#{from.name} (#{from.disambiguate_symbol || from.symbol}) " \
    "#{icon('fas', 'long-arrow-alt-right ')} " \
    "#{to.name} (#{to.disambiguate_symbol || to.symbol}) ".html_safe
  end
end
