module Conversions
  class AutomaticSynchronizer
    def self.call
      Conversion.syncable.each do |conversion|
        user = conversion.user

        if Oauth.new(user).refresh_token_if_needed!
          sync = Conversions::Initializer.call(conversion)
          Rollbar.info("Finalizing sync #{sync.id}", sync_id: sync.id, transactions_count: sync.transactions.count)
          count = Conversions::Finalizer.call(sync)
          Rollbar.info("Finalized sync #{sync.id}", sync_id: sync.id, transactions_count: count)
        else
          Rollbar.warn("Couldn't authenticate user #{user.id}")
        end
      rescue StandardError => e
        Rollbar.error(e, "Automatic conversion #{conversion.id} failed")
      end
    end
  end
end
