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

  desc "TODO"
  task delete_transactions: :environment do
  end

end
