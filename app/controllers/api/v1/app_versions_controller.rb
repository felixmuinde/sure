# frozen_string_literal: true

class Api::V1::AppVersionsController < Api::V1::BaseController
  # Public endpoint — version numbers are not sensitive and the check runs before login.
  skip_before_action :authenticate_request!
  skip_before_action :check_api_key_rate_limit
  skip_before_action :log_api_access

  # GET /api/v1/app_version
  def show
    result = Rails.cache.fetch("play_store_version", expires_in: 1.hour) do
      fetch_play_store_version
    end

    if result
      render_json({ version: result[:version], store_url: result[:store_url] })
    else
      render_json({ error: "unavailable" }, status: :service_unavailable)
    end
  end

  private

    def fetch_play_store_version
      package_name = Rails.application.config.x.play_store.package_name
      json_key = ENV.fetch("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON", nil)
      return nil if json_key.blank?

      creds = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(json_key),
        scope: "https://www.googleapis.com/auth/androidpublisher"
      )
      creds.fetch_access_token!

      response = Faraday.get(
        "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/#{package_name}/tracks/production",
        {},
        { "Authorization" => "Bearer #{creds.access_token}", "Accept" => "application/json" }
      )
      return nil unless response.status == 200

      data = JSON.parse(response.body)
      version = data.dig("releases", 0, "name")
      return nil unless version

      {
        version: version,
        store_url: "https://play.google.com/store/apps/details?id=#{package_name}"
      }
    rescue => e
      Rails.logger.error("AppVersionsController#fetch_play_store_version: #{e.message}")
      nil
    end
end
