require 'rails_helper'

describe Conversions::Finalizer do
  describe ".call" do
    subject { described_class.call(sync) }

    let(:sync) { create(:conversion_sync) }
    let(:adapter) { instance_double("YnabAdapter") }

    before do
      allow(YnabAdapter).to receive(:new).with(sync.add_on.user) { adapter }
      allow(adapter).to receive(:update_transaction)
    end

    it "uploads the changes to Ynab" do
      transaction_id = sync.transactions.first.id

      subject

      expect(adapter).to have_received(:update_transaction).with(
        args: {
          amount: 300,
          memo: "My memo"
        },
        budget_id: sync.add_on.ynab_budget_id,
        transaction_id: transaction_id
      )
    end

    it "marks the conversion as confirmed" do
      subject

      expect(sync).to be_confirmed
    end

    it "deletes the transactions" do
      subject

      expect(sync.transactions).to eq([])
    end

    it "returns the transaction count" do
      expect(subject).to eq(1)
    end

    it "sets the transactions count" do
      subject

      expect(sync.transactions_count).to eq(1)
    end
  end
end
