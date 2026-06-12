class Provider::MetabaseStudentAccount < Provider
  Error = Class.new(Provider::Error)

  StudentAccountData = Data.define(
    :email, :status, :total_financed, :repayments_received,
    :max_amount, :installments_paid, :max_installments, :currency
  )

  REQUIRED_COLUMNS = %w[
    email status total_financed repayments_received
    max_amount installments_paid max_installments
  ].freeze

  def initialize(base_url:, api_key:, question_id:, email_param: "email")
    @base_url = base_url
    @api_key = api_key # pipelock:ignore
    @question_id = question_id
    @email_param = email_param
  end

  def find_by_email(email)
    response = client.post("/api/card/#{@question_id}/query") do |req|
      req.body = {
        parameters: [
          {
            type: "category",
            target: [ "variable", [ "template-tag", @email_param ] ],
            value: email
          }
        ]
      }.to_json
    end

    result = JSON.parse(response.body)
    cols = result.dig("data", "cols")&.map { |c| c["name"] } || []
    rows = result.dig("data", "rows") || []

    missing = REQUIRED_COLUMNS - cols
    raise Error, "Missing columns in Metabase response: #{missing.join(', ')}" if missing.any?

    row = rows.first
    return nil if row.nil?

    idx = cols.each_with_object({}) { |c, h| h[c] = cols.index(c) }

    StudentAccountData.new(
      email:                row[idx["email"]].to_s,
      status:               row[idx["status"]].to_s,
      total_financed:       row[idx["total_financed"]].to_f,
      repayments_received:  row[idx["repayments_received"]].to_f,
      max_amount:           row[idx["max_amount"]].to_f,
      installments_paid:    row[idx["installments_paid"]].to_i,
      max_installments:     row[idx["max_installments"]].to_i,
      currency:             row[idx["currency"]]&.to_s || "KES"
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
