require "rails_helper"

BUDGET_ID = "da64e638-63f0-41fc-97a2-cc7f38c8b034"
ACCOUNT_ID = "c791437c-6660-4e86-b41e-50e70e6ff34d"
ACCOUNT_FOR_UPLOAD_ID = "eccab6f8-2d96-47b2-a19c-4c996a46ae65"
TRANSACTION_ID = "1ca525cb-4462-4687-adab-37796f3fd629"

describe YnabAdapter do
  subject { described_class.new(double(:user, ynab_access_token: Rails.application.credentials.ynab_api_key)) }

  describe "#budgets" do
    it "returns the budgets" do
      VCR.use_cassette("budgets") do
        budget = subject.budgets.find { |budget| budget.name == "Ynaby budget" }

        expect(budget).to be_a(Budget)
        expect(budget.id).to eq(BUDGET_ID)
        expect(budget.last_modified_on).to be_a(DateTime)

        currency_format = budget.currency_format

        expect(currency_format).to be_a(YNAB::CurrencyFormat)
        expect(currency_format.iso_code).to eq("EUR")
        expect(currency_format.example_format).to eq("123 456,78")
        expect(currency_format.decimal_digits).to eq(2)
        expect(currency_format.decimal_separator).to eq(",")
        expect(currency_format.symbol_first).to eq(false)
        expect(currency_format.group_separator).to eq(" ")
        expect(currency_format.currency_symbol).to eq("€")
        expect(currency_format.display_symbol).to eq(true)
      end
    end
  end

  describe "#accounts" do
    it "returns the accounts" do
      VCR.use_cassette("accounts") do
        account = subject.accounts(BUDGET_ID).find { |account| account.name == "My Checking Account" }

        expect(account).to be_a(Account)
        expect(account.id).to eq(ACCOUNT_ID)
        expect(account.type).to eq("checking")
        expect(account.on_budget).to eq(true)
        expect(account.closed).to eq(false)
        expect(account.note).to eq("Yada, yada")
        expect(account.balance).to eq(400000)
        expect(account.cleared_balance).to eq(-600000)
        expect(account.uncleared_balance).to eq(1000000)
        expect(account.transfer_payee_id).to eq("f808ff21-ebe2-42c6-ae8d-5375cf1f8c3f")
        expect(account.deleted).to eq(false)
      end
    end
  end

  describe "#transactions" do
    context "with date" do
      it "returns the transactions since that date" do
        VCR.use_cassette("transactions_with_date") do
          transaction = subject.transactions(
            since: Date.new(2018, 9, 28),
            budget_id: BUDGET_ID,
            account_id: ACCOUNT_ID
          ).find { |transaction| transaction.id == TRANSACTION_ID }

          expect(transaction).to be_a(Transaction)
          expect(transaction.date).to eq(Date.parse("28 Sep 2018"))
          expect(transaction.amount).to eq(-100000)
          expect(transaction.memo).to eq("Food")
          expect(transaction.cleared).to eq("cleared")
          expect(transaction.approved).to eq(true)
          expect(transaction.account_id).to eq(ACCOUNT_ID)
          expect(transaction.payee_id).to eq("dd836216-66a4-45e0-b63b-dc3df0baed86")
          expect(transaction.category_id).to eq("ee5a8690-45e6-49d3-af51-72ea104389e3")
          expect(transaction.deleted).to eq(false)
          expect(transaction.account_name).to eq("My Checking Account")
          expect(transaction.payee_name).to eq("Supermarket")
          expect(transaction.category_name).to eq("Groceries")
          expect(transaction.subtransactions).to eq([])
        end
      end
    end

    context "without date" do
      it "returns all transactions" do
        VCR.use_cassette("transactions_without_date") do
          transactions = subject.transactions(
            budget_id: BUDGET_ID,
            account_id: ACCOUNT_ID
          )

          expect(transactions.count).to eq(6)
        end
      end
    end
  end

  describe "#account" do
    it "returns the account" do
      VCR.use_cassette("account") do
        account = subject.account(
          budget_id: BUDGET_ID,
          account_id: ACCOUNT_ID
        )

        expect(account).to be_a(Account)
        expect(account.id).to eq(ACCOUNT_ID)
        expect(account.type).to eq("checking")
        expect(account.on_budget).to eq(true)
        expect(account.closed).to eq(false)
        expect(account.note).to eq("Yada, yada")
        expect(account.balance).to eq(400000)
        expect(account.cleared_balance).to eq(-600000)
        expect(account.uncleared_balance).to eq(1000000)
        expect(account.transfer_payee_id).to eq("f808ff21-ebe2-42c6-ae8d-5375cf1f8c3f")
        expect(account.deleted).to eq(false)
      end
    end
  end

  describe "#upload_transaction" do
    it "uploads the transaction" do
      VCR.use_cassette("transaction_upload") do
        args = {
          account_id: ACCOUNT_FOR_UPLOAD_ID,
          date: Date.new(2018, 9, 15),
          amount: -10000,
          memo: "A very long memo that will be limited to 50 characters",
          payee_name: "A very long payee name that will be limited to 50 characters"
        }

        transaction = subject.upload_transaction(
          args: args,
          budget_id: BUDGET_ID
        )

        expect(transaction.id).to be_present
        expect(transaction.date).to eq(Date.parse("15 Sep 2018"))
        expect(transaction.amount).to eq(-10000)
        expect(transaction.memo.length).to eq(50)
        expect(transaction.cleared).to eq("uncleared")
        expect(transaction.approved).to eq(false)
        expect(transaction.account_id).to eq(ACCOUNT_FOR_UPLOAD_ID)
        expect(transaction.payee_id).to be_present
        expect(transaction.deleted).to eq(false)
        expect(transaction.account_name).to eq("Uploading Account")
        expect(transaction.payee_name.length).to eq(50)
        expect(transaction.subtransactions).to eq([])
      end
    end
  end

  describe "#update_transaction" do
    it "updates the transaction" do
      VCR.use_cassette("transaction_update") do
        upload_args = {
          account_id: ACCOUNT_FOR_UPLOAD_ID,
          date: Date.new(2018, 9, 15),
          amount: -10000,
          memo: "Yada, yada",
          payee_name: "Kramer"
        }

        created_transaction = subject.upload_transaction(
          args: upload_args,
          budget_id: BUDGET_ID
        )

        update_args = {
          account_id: ACCOUNT_FOR_UPLOAD_ID,
          date: Date.new(2018, 10, 15),
          amount: -20000,
          memo: "Yada, yada, yada",
          payee_name: "Cosmo Kramer",
          payee_id: nil
        }

        updated_transaction = subject.update_transaction(
          args: update_args,
          transaction_id: created_transaction.id,
          budget_id: BUDGET_ID
        )

        expect(updated_transaction.id).to eq(created_transaction.id)
        expect(updated_transaction.date).to eq(Date.parse("15 Oct 2018"))
        expect(updated_transaction.amount).to eq(-20000)
        expect(updated_transaction.memo).to eq("Yada, yada, yada")
        expect(updated_transaction.cleared).to eq("uncleared")
        expect(updated_transaction.approved).to eq(false)
        expect(updated_transaction.account_id).to eq(ACCOUNT_FOR_UPLOAD_ID)
        expect(updated_transaction.payee_id).to be_present
        expect(updated_transaction.deleted).to eq(false)
        expect(updated_transaction.account_name).to eq("Uploading Account")
        expect(updated_transaction.payee_name).to eq("Cosmo Kramer")
        expect(updated_transaction.subtransactions).to eq([])
      end
    end
  end
end
