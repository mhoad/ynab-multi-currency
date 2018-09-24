require 'money/bank/open_exchange_rates_bank'

oxr = Money::Bank::OpenExchangeRatesBank.new(ExchangeRate)
oxr.app_id = Rails.application.credentials.open_exchange_rates_app_id

Money.default_bank = oxr
