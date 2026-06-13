class Provider::MetabaseStudentAccount < Provider
  Error = Class.new(Provider::Error)

  StudentAccountData = Data.define(
    :email, :status, :total_financed, :repayments_received,
    :max_amount, :installments_paid, :max_installments, :currency
  )

  REQUIRED_COLUMNS = %w[
    contact_email isa_status maximum_financed_amount
    repayment_period_months_r_1 monthly_repayment_percentage_r_1
  ].freeze

  def initialize(base_url:, api_key:, question_id:)
    @base_url = base_url
    @api_key = api_key # pipelock:ignore
    @question_id = question_id
  end

  def find_by_email(email)
    response = client.post("/api/card/#{@question_id}/query") do |req|
      req.body = "{}".freeze
    end

    result = JSON.parse(response.body)
    cols = result.dig("data", "cols")&.map { |c| c["name"] } || []
    rows = result.dig("data", "rows") || []

    missing = REQUIRED_COLUMNS - cols
    raise Error, "Missing columns in Metabase response: #{missing.join(', ')}" if missing.any?

    idx = cols.each_with_object({}) { |c, h| h[c] = cols.index(c) }
    email_col = idx["contact_email"]

    row = rows.find { |r| r[email_col].to_s.sub(/\A<TODO-MASK-PII>\s*/i, "").downcase == email.downcase }
    return nil if row.nil?

    StudentAccountData.new(
      email:                  row[email_col].to_s.sub(/\A<TODO-MASK-PII>\s*/i, ""),
      status:                 row[idx["isa_status"]].to_s,
      total_financed:         row[idx["total_invoiced"]].to_f,
      repayments_received:    row[idx["total_payment_amount"]].to_f,
      max_amount:             row[idx["maximum_financed_amount"]].to_f,
      installments_paid:      row[idx["installments_paid"]].to_i,
      max_installments:       row[idx["repayment_period_months_r_1"]].to_i,
      currency:               row[idx["invoice_currency"]]&.to_s || "KES"
    )
  end

  private

    def client
      @client ||= Faraday.new(url: @base_url) do |f|
        f.request :retry, max: 2, interval: 0.5, backoff_factor: 2,
                          exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [ Faraday::ConnectionFailed ]
        f.response :raise_error
        f.headers["X-API-KEY"] = @api_key
        f.headers["Content-Type"] = "application/json"
      end
    end
end
