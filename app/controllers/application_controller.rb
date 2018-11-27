class ApplicationController < ActionController::Base
  private

  def authorize_ynab!
    begin
      if current_user.requires_ynab_authorization?
        return redirect_to new_oauth_path
      end

      yield

    rescue YNAB::ApiError => e
      if e.message == "Unauthorized"
        return redirect_to new_oauth_path
      else
        logger.fatal("#{e.code} | #{e.message} | #{e.name} | #{e.detail}")
        logger.fatal(e.response_body)
        raise
      end
    end
  end
end
