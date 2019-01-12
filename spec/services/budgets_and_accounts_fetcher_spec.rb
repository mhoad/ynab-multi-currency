require 'rails_helper'

describe BudgetsAndAccountsFetcher do
  describe ".call" do
    let(:user) { create(:user) }
    let(:raw_budget) { YNAB::BudgetSummary.new(id: "1234") }
    let(:raw_account) { YNAB::Account }
    let(:adapter) { instance_double("YnabAdapter") }

    it "returns anr array with the budgets" do
      allow(YnabAdapter).to receive(:new).with(user) { adapter }
      allow(adapter).to receive(:budgets) { [raw_budget] }
      allow(adapter).to receive(:accounts).with("1234") { [raw_account] }

      budget = described_class.call(user).first

      expect(budget).to be_a(Budget)
      expect(budget.id).to eq("1234")
      expect(budget.accounts).to eq([raw_account])
    end
  end
end
