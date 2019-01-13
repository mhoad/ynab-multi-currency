require 'rails_helper'

describe Conversions::AutomaticSynchronizer do
  describe ".call" do
    subject { described_class.call }

    let!(:conversion) { create(:conversion, :syncable) }
    let!(:deleted_conversion) { create(:conversion, :syncable, :deleted) }
    let!(:non_auto_conversion) { create(:conversion, :syncable, sync_automatically: false) }
    let!(:unsynced_conversion) { create(:conversion, :syncable, syncs: []) }

    let(:oauth) { double(:oauth, refresh_token_if_needed!: oauth_result) }
    let(:oauth_result) { true }

    let(:sync) { create(:conversion_sync) }

    before do
      allow(Oauth).to receive(:new).with(conversion.user) { oauth }
      allow(Conversions::Initializer).to receive(:call) { sync }
      allow(Conversions::Finalizer).to receive(:call) { 1 }
    end

    it "refreshes the token if needed" do
      subject

      expect(oauth).to have_received(:refresh_token_if_needed!)
    end

    context "when the token can't be refreshed" do
      let(:oauth_result) { false }

      it "aborts the sync" do
        subject

        expect(Conversions::Initializer).to_not have_received(:call)
        expect(Conversions::Finalizer).to_not have_received(:call)
      end

      it "logs a warning" do
        expect(Rollbar).to receive(:warn).with(/Couldn't authenticate user \d+/)

        subject
      end
    end

    it "converts and uploads the transactions" do
      subject

      expect(Conversions::Initializer).to have_received(:call).with(conversion)
      expect(Conversions::Finalizer).to have_received(:call).with(sync)
    end

    it "excludes deleted conversions" do
      subject

      expect(Conversions::Initializer).to_not have_received(:call).with(deleted_conversion)
    end

    it "excludes non-automatic conversions" do
      subject

      expect(Conversions::Initializer).to_not have_received(:call).with(non_auto_conversion)
    end

    it "excludes conversions that have never been synced" do
      subject

      expect(Conversions::Initializer).to_not have_received(:call).with(unsynced_conversion)
    end

    it "logs the transaction counts" do
      expect(Rollbar).to receive(:info).with(/Finalizing sync \d+/, sync_id: sync.id, transactions_count: 1)
      expect(Rollbar).to receive(:info).with(/Finalized sync \d+/, sync_id: sync.id, transactions_count: 1)

      subject
    end

    context "when there's an error" do
      it "rescues and logs the error" do
        error = StandardError.new("Something is wrong")
        allow(Conversions::Initializer).to receive(:call).and_raise(error)

        expect(Rollbar).to receive(:error).with(error, /Automatic conversion \d+ failed/)

        subject
      end
    end
  end
end
