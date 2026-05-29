module Invitable
  extend ActiveSupport::Concern

  included do
    helper_method :invite_code_required?
  end

  private
    def invite_code_required?
      return false if @invitation.present?
      if self_hosted?
        Setting.onboarding_state == "invite_only" && Setting.invite_only_default_family_id.blank?
      else
        ENV["REQUIRE_INVITE_CODE"] == "true"
      end
    end

    def assign_signup_family_and_role(user, invitation: nil)
      if invitation.present?
        user.family = invitation.family
        user.role = invitation.role
        user.email = invitation.email if user.respond_to?(:email=)
      elsif (default_family = invite_only_default_family)
        user.family = default_family
        user.role = :member
      else
        user.family = Family.new
        user.role = User.role_for_new_family_creator
      end
    end

    def invite_only_default_family
      default_family_id = Setting.invite_only_default_family_id
      return unless default_family_id.present? && Setting.onboarding_state == "invite_only"

      Family.find_by(id: default_family_id)
    end

    def self_hosted?
      Rails.application.config.app_mode.self_hosted?
    end
end
