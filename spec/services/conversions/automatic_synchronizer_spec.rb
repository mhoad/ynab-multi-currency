require 'rails_helper'

describe Conversions::AutomaticSynchronizer do
  describe ".call" do
    subject { described_class.call }

    let!(:conversion) { create(:conversion) }
    let(:oauth) { double(:oauth, refresh_token_if_needed!: oauth_result) }
    let(:oauth_result) { true }
    let(:sync) { create(:conversion_sync, add_on: conversion) }

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

    context "when the conversion is deleted" do
      let(:conversion) { create(:conversion, :deleted) }

      it "excludes deleted conversions" do
        subject

        expect(Conversions::Initializer).to_not have_received(:call).with(conversion)
      end
    end

    context "when the conversion is not automatic" do
      let(:conversion) { create(:conversion, sync_automatically: false) }

      it "excludes non-automatic conversions" do
        subject

        expect(Conversions::Initializer).to_not have_received(:call).with(conversion)
      end
    end

    context "when there's an error" do
      it "rescues and logs the error" do
        error = StandardError.new("Something is wrong")
        allow(Conversions::Initializer).to receive(:call).and_raise(error)

        expect(Rollbar).to receive(:error).with(error, /Automatic conversion \d+ failed/)

        subject
      end
    end

    context "when there is nothing to convert" do
      let(:sync) { nil }

      it "does not call the finalizer" do
        conversion

        subject

        expect(Conversions::Finalizer).to_not have_received(:call)
      end
    end
  end
end
