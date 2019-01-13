namespace :ynab_multi_currency do
  desc "Converts transactions and uploads them to YNAB"
  task sync_accounts: :environment do
    Conversions::AutomaticSynchronizer.call
  end

  desc "Deletes stale transactions from unconfirmed syncs"
  task delete_stale_transactions: :environment do
    count = Sync.delete_stale_transactions
    puts "Deleted transactions from #{count} stale syncs"
  end

  desc "Download exchange rates"
  task fetch_exchange_rates: :environment do
    rates = Money.default_bank.update_rates
    puts "Fetched #{rates.count} rates"
  end

  desc "Fill type in add_ons"
  task fill_type_in_add_ons: :environment do
    count = AddOn.count
    AddOn.update_all(type: "Conversion")
    puts "Added Conversion type to #{count} AddOns"
  end
end
