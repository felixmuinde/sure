class Api::V1::MyAccountController < Api::V1::BaseController
  before_action :ensure_read_scope

  # GET /api/v1/my_account
  def show
    url     = Setting.metabase_url.presence
    api_key = Setting.metabase_api_key.presence
    qid     = Setting.metabase_student_question_id.presence
    param   = Setting.metabase_email_param.presence || "email"

    unless url && api_key && qid
      return render_json(
        { error: "not_configured", message: "Metabase integration is not configured" },
        status: :service_unavailable
      )
    end

    provider = Provider::MetabaseStudentAccount.new(
      base_url: url, api_key: api_key, question_id: qid, email_param: param
    )

    account = provider.find_by_email(current_resource_owner.email)

    if account.nil?
      return render_json(
        { error: "not_found", message: "No student account found for this user" },
        status: :not_found
      )
    end

    render_json({
      email:                account.email,
      status:               account.status,
      total_financed:       account.total_financed,
      repayments_received:  account.repayments_received,
      max_amount:           account.max_amount,
      installments_paid:    account.installments_paid,
      max_installments:     account.max_installments,
      currency:             account.currency
    })
  rescue Provider::MetabaseStudentAccount::Error => e
    Rails.logger.error "Metabase provider error: #{e.message}"
    render_json({ error: "provider_error", message: e.message }, status: :bad_gateway)
  end
end
