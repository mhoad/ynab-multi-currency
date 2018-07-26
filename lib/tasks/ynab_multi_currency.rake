namespace :ynab_multi_currency do
  desc "Converts transactions and uploads them to YNAB"
  task sync_accounts: :environment do
    Conversion.syncable.each do |conversion|
      count = conversion.create_draft_sync.confirm!
      puts "#{count} converted for conversion #{conversion.id}"
    rescue
      puts "Conversion #{conversion.id} failed"
    end
  end

  desc "Deletes stale transactions from unconfirmed syncs"
  task delete_stale_transactions: :environment do
    count = Sync.delete_stale_transactions
    puts "Deleted transactions from #{count} stale syncs"
  end

end
