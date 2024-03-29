require 'rails_helper'

RSpec.describe "Conversions", type: :request do
  let(:user) { create(:user) }

  before do
    allow(BudgetsAndAccountsFetcher).to receive(:call) { [build(:budget)] }
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
        allow(Conversions::Initializer).to receive(:call) { sync }
        sign_in(user)
      end

      let(:sync) { user.conversions.last.syncs.create }

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

        context "when there is nothing to convert" do
          let(:sync) { nil }

          it "redirects to the add_ons index" do
            expect(response).to redirect_to(add_ons_path)
            expect(flash[:alert]).to eq("No transactions found to convert")
          end
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
        before do
          sign_in(user)
          allow(Conversions::Initializer).to receive(:call) { sync }
        end
        let(:sync) { conversion.syncs.create }

      it "creates a sync" do
        post conversion_syncs_path(conversion)

        expect(response).to redirect_to(edit_conversion_sync_path(conversion, sync))
      end

      context "when there is nothing to convert" do
        let(:sync) { nil }

        it "redirects to the add_on index" do
          post conversion_syncs_path(conversion)

          expect(response).to redirect_to(add_ons_path)
          expect(flash[:alert]).to eq("No transactions found to convert")
        end
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
          allow(Conversions::Initializer).to receive(:call) { create(:conversion_sync, add_on: conversion) }

          sign_in(user)
          get edit_conversion_sync_path(conversion, sync)

          expect(Conversions::Initializer).to have_received(:call).with(conversion)
          expect(response).to have_http_status(200)
          expect(response).to render_template(:edit)
        end

        context "when there is nothing to sync" do
          it "redirects to the add_ons index" do
            allow(Conversions::Initializer).to receive(:call) { nil }

            sign_in(user)
            get edit_conversion_sync_path(conversion, sync)

            expect(response).to redirect_to(add_ons_path)
            expect(flash[:alert]).to eq("No transactions found to convert")
          end
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
        allow(Conversions::Finalizer).to receive(:call)

        sign_in(user)
        put conversion_sync_path(conversion, sync)

        expect(Conversions::Finalizer).to have_received(:call).with(sync)
        expect(response).to redirect_to(add_ons_path)
      end

      context "when there are no transactions to sync" do
        let(:sync) { create(:conversion_sync, add_on: conversion, transactions: []) }
        let(:new_sync) { create(:conversion_sync, add_on: conversion) }

        before do
          allow(Conversions::Initializer).to receive(:call) { new_sync }
          sign_in(user)
        end

        it "creates a new sync and redirects to the edit page" do
          put conversion_sync_path(conversion, sync)

          expect(Conversions::Initializer).to have_received(:call).with(conversion)
          expect(response).to redirect_to edit_conversion_sync_path(conversion, new_sync)
          expect(flash[:alert]).to eq("Oops! You took too long to confirm your transactions so we had to cancel the operation. Here's a fresh batch for you to review again.")
        end

        context "when the new sync is nil" do
          let(:new_sync) { nil }

          it "redirects to add_ons index" do
            put conversion_sync_path(conversion, sync)

            expect(response).to redirect_to(add_ons_path)
            expect(flash[:alert]).to eq("Oops! Your transactions are no longer available to convert.")
          end
        end
      end
    end
  end
end
