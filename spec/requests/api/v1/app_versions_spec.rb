# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "API V1 App Version", type: :request do
  path "/api/v1/app_version" do
    get "Get latest app version" do
      tags "App Version"
      produces "application/json"
      description "Returns the latest published version of the app from the Play Store. " \
                  "Public endpoint — no authentication required."

      response "200", "version available" do
        schema type: :object,
               required: %w[version store_url],
               properties: {
                 version: { type: :string, example: "1.2.3" },
                 store_url: { type: :string, format: :uri, example: "https://play.google.com/store/apps/details?id=am.sure.mobile" }
               }

        before do
          allow_any_instance_of(Api::V1::AppVersionsController)
            .to receive(:fetch_play_store_version)
            .and_return({ version: "1.2.3", store_url: "https://play.google.com/store/apps/details?id=am.sure.mobile" })
          Rails.cache.clear
        end

        run_test!
      end

      response "503", "Play Store API unavailable" do
        schema type: :object,
               required: %w[error],
               properties: {
                 error: { type: :string, example: "unavailable" }
               }

        before do
          allow_any_instance_of(Api::V1::AppVersionsController)
            .to receive(:fetch_play_store_version)
            .and_return(nil)
          Rails.cache.clear
        end

        run_test!
      end
    end
  end
end
