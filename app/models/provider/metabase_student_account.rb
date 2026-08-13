class Provider::MetabaseStudentAccount < Provider
  Error = Class.new(Provider::Error)

  StudentAccountData = Data.define(
    :email,
    :status,
    :total_financed,
    :repayments_received,
    :max_amount,
    :installments_paid,
    :max_installments,
    :currency
  )

  def initialize(url:, api_key:, question_id:, email_param: "email")
    @url         = url.chomp("/")
    @api_key     = api_key
    @question_id = question_id
    @email_param = email_param
  end

  def find_by_email(email)
    response = connection.post(
      "/api/card/#{@question_id}/query",
      { parameters: [ { type: "category", target: [ "variable", [ "template-tag", @email_param ] ], value: email } ] }.to_json,
      { "Content-Type" => "application/json", "X-API-KEY" => @api_key }
    )

    raise Error, "Metabase returned #{response.status}" unless response.success?

    body = JSON.parse(response.body)
    cols = body.dig("data", "cols")&.map { |c| c["name"] } || []
    rows = body.dig("data", "rows") || []

    # Strip the <TODO-MASK-PII> prefix Metabase adds to sensitive columns
    row = rows.find { |r| strip_pii(r[cols.index("contact_email")]) == email.downcase }
    return nil unless row

    def_at = ->(col) { row[cols.index(col)] }

    StudentAccountData.new(
      email:               strip_pii(def_at.("contact_email")).to_s,
      status:              def_at.("isa_status").to_s,
      total_financed:      def_at.("maximum_financed_amount").to_f,
      repayments_received: def_at.("total_payment_amount").to_f,
      max_amount:          def_at.("maximum_financed_amount").to_f,
      installments_paid:   def_at.("installments_paid").to_i,
      max_installments:    def_at.("repayment_period_months_r_1").to_i,
      currency:            def_at.("invoice_currency").to_s.presence || "KES"
    )
  rescue Faraday::Error => e
    raise Error, "Metabase connection error: #{e.message}"
  end

  private

    def strip_pii(value)
      value.to_s.sub(/\A<TODO-MASK-PII>/i, "").downcase
    end

    def connection
      @connection ||= Faraday.new(url: @url) do |f|
        f.request :retry, max: 2, interval: 0.5
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end
end
