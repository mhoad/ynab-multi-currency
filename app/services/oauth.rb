class Oauth
  def initialize(user)
    @user = user
  end

  def authorization_url
    "https://app.youneedabudget.com/oauth/authorize" \
    "?client_id=#{client_id}" \
    "&redirect_uri=#{redirect_uri}" \
    "&response_type=code"
  end

  def authorize!(code)
    response = HTTParty.post(token_url(code)).parsed_response

    @user.update!(
      ynab_access_token: response["access_token"],
      ynab_token_type: response["token_type"],
      ynab_expires_at: token_expiration_time(response),
      ynab_refresh_token: response["refresh_token"]
    )
  end

  def refresh!
    response = HTTParty.post(refresh_url).parsed_response

    if response["error"].blank?
      @user.update!(
        ynab_access_token: response["access_token"],
        ynab_token_type: response["token_type"],
        ynab_expires_at: token_expiration_time(response),
        ynab_refresh_token: response["refresh_token"]
      )
    end
  end

  private

  def token_url(code)
    "https://app.youneedabudget.com/oauth/token" \
    "?client_id=#{client_id}" \
    "&client_secret=#{client_secret}" \
    "&redirect_uri=#{redirect_uri}" \
    "&grant_type=authorization_code" \
    "&code=#{code}"
  end

  def refresh_url
    "https://app.youneedabudget.com/oauth/token" \
    "?client_id=#{client_id}" \
    "&client_secret=#{client_secret}" \
    "&grant_type=refresh_token" \
    "&refresh_token=#{@user.ynab_refresh_token}"
  end

  def client_id
    Rails.application.credentials.ynab_client_id
  end

  def client_secret
    Rails.application.credentials.ynab_client_secret
  end

  def redirect_uri
    Rails.application.credentials[:ynab_redirect_uri][Rails.env.to_sym]
  end

  def token_expiration_time(response)
    Time.at(response["created_at"]) + response["expires_in"].seconds
  end
end
