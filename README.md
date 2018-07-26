# Ynab Multi-Currency

Rails application to manage [YNAB](https://www.youneedabudget.com/) accounts with multiple currencies in a single budget.

It works by automatically converting your foreign account's transactions to your YNAB budget currency.

Check out the [demo app](https://ynab-multi-currency.herokuapp.com/).

## Development set up

1. Install all gems

```
bundle install
```

2. Set up the database

```
rails db:setup
```
3. Create a blank credentials file

```
rm config/credentials.yml.enc
rails credentials:edit
```
This will remove the encrypted credentials that come with this repo and create a blank `credentials.yml.enc` and its corresponding `master.key`.

4. The command above will have opened the credentials file in an editor. Add your own secrets following this template:

```yml
open_exchange_rates_app_id: my_secret

ynab_client_id:
  development: my_secret
  production: my_secret

ynab_client_secret:
  development: my_secret
  production: my_secret

ynab_redirect_uri:
  development: urn:ietf:wg:oauth:2.0:oob
  production: https://my-website.com/oauth
```

5. If deploying to Heroku, add the master key to your env variables. **Never commit the master key**.

```
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
```
