require "rails_helper"

describe Budget do
  subject do
    described_class.new(
      YNAB::BudgetSummary.new(
        id: "1234",
        currency_format: double(:currency, iso_code: "EUR")
      )
    )
  end

  let(:accounts) { [] }

  describe "delegation" do
    it "delegates methods to the child object" do
      expect(subject.id).to eq("1234")
    end
  end

  describe "#initialize" do
    context "when no accouts are set on initialization" do
      it "returns an empty array" do
        expect(subject.accounts).to eq([])
      end
    end

    context "when accounts are set" do
      subject do
        described_class.new(
          YNAB::BudgetSummary.new(
            id: "1234",
            currency_format: double(:currency, iso_code: "EUR")
          ),
          accounts: accounts
        )
      end

      let(:accounts) { [YNAB::Account.new] }

      it "returns the accounts" do
        expect(subject.accounts).to eq(accounts)
      end
    end
  end

  describe "#accounts" do
    it "sets and gets accounts" do
      subject.accounts = "My accounts"
      expect(subject.accounts).to eq("My accounts")
    end
  end

  describe "#currency_code" do
    it "returns the iso_code" do
      expect(subject.currency_code).to eq("EUR")
    end
  end
end
