module Conversions
  class AutomaticSynchronizer
    def self.call
      Conversion.syncable.each do |conversion|
        user = conversion.user

        if Oauth.new(user).refresh_token_if_needed!
          sync = Conversions::Initializer.call(conversion)
          Conversions::Finalizer.call(sync)
        else
          Rollbar.warn("Couldn't authenticate user #{user.id}")
        end
      rescue StandardError => e
        Rollbar.error(e, "Automatic conversion #{conversion.id} failed")
      end
    end
  end
end
