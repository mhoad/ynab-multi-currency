require 'rails_helper'

describe BudgetsAndAccountsFetcher do
  describe ".call" do
    let(:user) { create(:user) }
    let(:budget) { build(:budget, id: "1234") }
    let(:account) { build(:account) }
    let(:adapter) { instance_double("YnabAdapter") }

    it "returns anr array with the budgets and accounts" do
      allow(YnabAdapter).to receive(:new).with(user) { adapter }
      allow(adapter).to receive(:budgets) { [budget] }
      allow(adapter).to receive(:accounts).with("1234") { [account] }

      response_budget = described_class.call(user).first

      expect(response_budget).to be_a(Budget)
      expect(response_budget.id).to eq("1234")
      expect(response_budget.accounts).to eq([account])
    end
  end
end
