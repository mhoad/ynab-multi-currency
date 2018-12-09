require 'rails_helper'

RSpec.describe "Conversions", type: :request do
  let(:user) { create(:user) }
  let(:budget) { build(:ynab_budget) }

  before do
    allow(user).to receive(:ynab_budgets) { [budget] }
    allow(budget).to receive(:accounts) { [build(:ynab_account)] }
  end

  describe "GET /conversions" do
    context "when the user is not authenticated" do
      it "redirects to the login page" do
        get conversions_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "redirects to the add_ons index" do
        sign_in(user)
        get conversions_path
        expect(response).to redirect_to(add_ons_path)
      end
    end
  end

  describe "GET /conversions/new" do
    context "when the user is not authenticated" do
      it "redirects to the login page" do
        get new_conversion_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "renders the new conversions form" do
        sign_in(user)
        get new_conversion_path

        expect(response).to have_http_status(200)
        expect(response).to render_template(:new)
        expect(response.body).to include("Conversion setup")
      end
    end
  end

  describe "POST /conversions" do
    context "when the user is not authenticated" do
      it "redirects to the login page" do
        post conversions_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        allow(CurrencyConverter).to receive(:call) do
          user.conversions.last.syncs.create
        end

        sign_in(user)
      end

      context "when the conversion is valid" do
        before do
          post conversions_path, params: {
            conversion: {
              cached_ynab_account_name:	"Checking Account",
              cached_ynab_budget_name: "My budget",
              from_currency: "USD",
              memo_position: "left",
              offset: "0.1",
              start_date:	"08/12/2018",
              sync_automatically:	"0",
              to_currency: "EUR",
              ynab_account_id: "ABC",
              ynab_budget_id:	"DEF"
            }
          }
        end

        it "creates a conversion" do
          conversion = Conversion.last

          expect(conversion.cached_ynab_account_name).to eq("Checking Account")
          expect(conversion.cached_ynab_budget_name).to eq("My budget")
          expect(conversion.from_currency).to eq("USD")
          expect(conversion.memo_position).to eq("left")
          expect(conversion.offset).to eq(0.1)
          expect(conversion.start_date).to eq(Date.parse("08/12/2018"))
          expect(conversion.sync_automatically).to eq(false)
          expect(conversion.to_currency).to eq("EUR")
          expect(conversion.ynab_account_id).to eq("ABC")
          expect(conversion.ynab_budget_id).to eq("DEF")
        end

        it "redirects to the sync confirmation page" do
          expect(response).to redirect_to(edit_conversion_sync_path(Conversion.last, Sync.last))
        end
      end

      context "when the conversion is invalid" do
        it "renders the edit form" do
          post conversions_path, params: { conversion: { yolo: "yolo" } }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "GET /conversions/:id" do
    let(:conversion) { create(:conversion, user: user) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        get edit_conversion_path(conversion)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "redirects to the conversions edit" do
        sign_in(user)
        get edit_conversion_path(conversion)

        expect(response).to have_http_status(200)
        expect(response).to render_template(:edit)
        expect(response.body).to include("Modify your conversion setup")
      end
    end
  end

  describe "PUT /conversions/:id" do
    let(:conversion) { create(:conversion, user: user) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        put conversion_path(conversion)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      before do
        sign_in(user)
      end

      context "when the conversion is valid" do
        before do
          put conversion_path(conversion), params: {
            conversion: {
              cached_ynab_account_name:	"Savings Account",
            }
          }
        end

        it "updates the conversion" do
          expect(conversion.reload.cached_ynab_account_name).to eq("Savings Account")
        end

        it "redirects to the add_ons index" do
          expect(response).to redirect_to(add_ons_path)
        end
      end

      context "when the conversion is invalid" do
        it "renders the edit form" do
          put conversion_path(conversion), params: { conversion: { to_currency: "yolo" } }
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "DELETE /conversions/:id" do
    let(:conversion) { create(:conversion, user: user) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        delete conversion_path(conversion)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "redirects to the conversions edit" do
        sign_in(user)
        delete conversion_path(conversion)
        expect(response).to redirect_to(add_ons_path)
      end
    end
  end

  describe "POST /conversions/:id/syncs" do
    let(:conversion) { create(:conversion, user: user) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        post conversion_syncs_path(conversion)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "creates a sync" do
        sign_in(user)
        sync = conversion.syncs.create

        allow(CurrencyConverter).to receive(:call) { sync }

        post conversion_syncs_path(conversion)

        expect(response).to redirect_to(edit_conversion_sync_path(conversion, sync))
      end
    end
  end

  describe "GET /conversions/:conversion_id/syncs/:id/edit" do
    let(:conversion) { create(:conversion, user: user) }
    let(:sync) { create(:conversion_sync, add_on: conversion) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        get edit_conversion_sync_path(conversion, sync)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "renders the sync edit page" do
        sign_in(user)
        get edit_conversion_sync_path(conversion, sync)

        expect(response).to have_http_status(200)
        expect(response).to render_template(:edit)
        expect(response.body).to include("Review your transactions")
      end

      context "when the sync was already confirmed" do
        let(:sync) { create(:conversion_sync, add_on: conversion, confirmed: true) }

        it "creates a new draft sync" do
          allow(CurrencyConverter).to receive(:call) { create(:conversion_sync, add_on: conversion) }

          sign_in(user)
          get edit_conversion_sync_path(conversion, sync)

          expect(CurrencyConverter).to have_received(:call).with(conversion)
          expect(response).to have_http_status(200)
          expect(response).to render_template(:edit)
        end
      end

      context "when there are no transactions to sync" do
        let(:sync) { create(:conversion_sync, add_on: conversion, transactions: []) }

        it "redirects to the add_ons index" do
          sign_in(user)
          get edit_conversion_sync_path(conversion, sync)
          expect(response).to redirect_to(add_ons_path)
        end
      end
    end
  end

  describe "PUT /conversions/:conversion_id/syncs/:id" do
    let(:conversion) { create(:conversion, user: user) }
    let(:sync) { create(:conversion_sync, add_on: conversion) }

    context "when the user is not authenticated" do
      it "redirects to the login page" do
        put conversion_sync_path(conversion, sync)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is authenticated" do
      it "confirms the sync and redirects to the add_ons path" do
        allow(sync).to receive(:confirm!)

        put conversion_sync_path(conversion, sync)

        expect(sync).to have_received(:confirm!)
        expect(response).to redirect_to(add_ons_path)
      end

      context "when there are no transactions to sync" do
        let(:sync) { create(:conversion_sync, add_on: conversion, transactions: []) }
        let(:new_sync) { create(:conversion_sync, add_on: conversion) }

        it "creates a new sync and redirects to the edit page" do
          allow(CurrencyConverter).to receive(:call) { new_sync }

          sign_in(user)
          put conversion_sync_path(conversion, sync)

          expect(CurrencyConverter).to have_received(:call).with(conversion)
          expect(response).to redirect_to edit_conversion_sync_path(conversion, new_sync)
        end
      end
    end
  end
end
