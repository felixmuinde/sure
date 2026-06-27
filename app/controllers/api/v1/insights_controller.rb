# frozen_string_literal: true

class Api::V1::InsightsController < Api::V1::BaseController
  before_action :ensure_read_scope

  def show
    data = SheetInsightsFetcher.new.fetch_for_email(current_resource_owner.email)
    render json: { insights: data }
  rescue SheetInsightsFetcher::NotFoundError
    render json: { error: "not_found", message: "No ISA data found for your account." }, status: :not_found
  rescue SheetInsightsFetcher::ConfigurationError => e
    Rails.logger.error "InsightsController: #{e.message}"
    render json: { error: "service_unavailable", message: "ISA data service is not configured." }, status: :service_unavailable
  rescue SheetInsightsFetcher::Error => e
    Rails.logger.error "InsightsController: #{e.message}"
    render json: { error: "service_unavailable", message: "Unable to load ISA data. Please try again later." }, status: :service_unavailable
  end

  private

    def ensure_read_scope
      authorize_scope!(:read)
    end
end
