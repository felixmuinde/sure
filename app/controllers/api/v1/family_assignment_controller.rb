# frozen_string_literal: true

class Api::V1::FamilyAssignmentController < Api::V1::BaseController
  def create
    country_code = params[:country_code].to_s.upcase.presence
    return render json: { error: "country_code is required" }, status: :unprocessable_entity unless country_code

    target_family = Family.find_by(country: country_code)
    return render json: { error: "No family found for country #{country_code}" }, status: :not_found unless target_family

    if target_family == Current.user.family
      render json: family_json(target_family), status: :ok
      return
    end

    Current.user.update!(family_id: target_family.id)
    render json: family_json(target_family), status: :ok
  end

  private

    def family_json(family)
      {
        family: {
          id: family.id,
          name: family.name,
          currency: family.currency,
          locale: family.locale,
          country: family.country
        }
      }
    end
end
