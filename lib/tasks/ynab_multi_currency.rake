namespace :ynab_multi_currency do
  desc "Converts transactions and uploads them to YNAB"
  task sync_accounts: :environment do
    Conversion.syncable.each do |conversion|
      user = conversion.user

      if user.refresh_ynab_token_if_needed!
        count = conversion.create_draft_sync.confirm!
        puts "#{count} converted for conversion #{conversion.id}"
      else
        puts "Couldn't authenticate user #{user.id}"
      end
    rescue
      puts "Conversion #{conversion.id} failed"
    end
  end

  desc "Deletes stale transactions from unconfirmed syncs"
  task delete_stale_transactions: :environment do
    count = Sync.delete_stale_transactions
    puts "Deleted transactions from #{count} stale syncs"
  end

  desc "Initial download of the exchange rates"
  task fetch_exchange_rates: :environment do
    rates = Money.default_bank.update_rates
    puts "Fetched #{rates.count} rates"
  end
end
