require 'rails_helper'

describe Conversions::Initializer do
  describe ".call" do
    subject { described_class.call(conversion) }

    let(:conversion) do
      create(
        :conversion,
        start_date: Date.new(2019, 1, 10),
        memo_position: memo_position,
        offset: offset
      )
    end

    let(:adapter) { instance_double("YnabAdapter") }
    let(:transaction) { build(:transaction, amount: -100000, memo: memo) }

    let(:memo) { "Food" }
    let(:memo_position) { "left" }
    let(:offset) { nil }

    before(:all) do
      ExchangeRate.add_rate("USD", "EUR", 0.5)
    end

    before do
      allow(YnabAdapter).to receive(:new).with(conversion.user) { adapter }
      allow(adapter).to receive(:transactions) { [transaction] }
    end

    it "gets the account transactions since the start date" do
      subject

      expect(adapter).to have_received(:transactions).with(
        since: Date.new(2019, 1, 10),
        budget_id: conversion.ynab_budget_id,
        account_id: conversion.ynab_account_id
      )
    end

    it "returns a Sync object" do
      expect(subject).to be_a(Sync)
    end

    it "converts the amount" do
      expect(subject.transactions.first.amount).to eq(-50000)
    end

    it "prepends a memo" do
      expect(subject.transactions.first.memo).to eq("US$-100.00 (FX rate: 0.5) · Food")
    end

    context "when there's a custom memo position" do
      let(:memo_position) { "right" }

      it "adds the memo to the right" do
        expect(subject.transactions.first.memo).to eq("Food · US$-100.00 (FX rate: 0.5)")
      end
    end

    context "when the memo is over 50 characters (left position)" do
      let(:memo) { "This is a very very long memo that will end up being truncated" }

      it "truncates it" do
        expect(subject.transactions.first.memo).to eq("US$-100.00 (FX rate: 0.5) · This is a very very lo")
      end
    end

    context "when the memo is over 50 characters (right position)" do
      let(:memo) { "This is a very very long memo that will end up being truncated" }
      let(:memo_position) { "right" }

      it "truncates it" do
        expect(subject.transactions.first.memo).to eq("This is a very very lo · US$-100.00 (FX rate: 0.5)")
      end
    end

    context "when there was no memo" do
      let(:memo) { "" }

      it "does not add a separator" do
        expect(subject.transactions.first.memo).to eq("US$-100.00 (FX rate: 0.5)")
      end
    end

    context "when there's an offset" do
      let(:offset) { 10 }

      it "multiplies the amount by the offset before conversion" do
        expect(subject.transactions.first.amount).to eq(-500000)
      end

      it "adds the correct amount to the memo" do
        expect(subject.transactions.first.memo).to eq("US$-1,000.00 (FX rate: 0.5) · Food")
      end
    end

    context "when the transaction has a conversion prefix" do
      let(:memo) { "FX rate" }

      it "skips the conversion" do
        expect(subject.transactions).to eq([])
      end
    end

    context "when the transaction has deprecated conversion prefix" do
      let(:memo) { "CX rate" }

      it "skips the conversion" do
        expect(subject.transactions).to eq([])
      end
    end

    context "when the transaction has a skip keyword" do
      let(:memo) { "skip" }

      it "skips the conversion" do
        expect(subject.transactions).to eq([])
      end
    end

    context "when the transaction has subtransactions" do
      let(:transaction) { build(:transaction, :with_subtransactions, amount: -100000, memo: memo) }

      it "skips the conversion" do
        expect(subject.transactions).to eq([])
      end
    end
  end
end
