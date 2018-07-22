require 'money/bank/open_exchange_rates_bank'

oxr = Money::Bank::OpenExchangeRatesBank.new(ExchangeRate)
oxr.app_id = Rails.application.credentials.open_exchange_rates_app_id
oxr.ttl_in_seconds = 86400
oxr.force_refresh_rate_on_expire = true

Money.default_bank = oxr
