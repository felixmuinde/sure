# frozen_string_literal: true

class SheetInsightsFetcher
  Error              = Class.new(StandardError)
  NotFoundError      = Class.new(Error)
  ConfigurationError = Class.new(Error)

  CACHE_KEY    = "sheet_insights_all_rows"
  CACHE_TTL    = 23.hours
  EMAIL_COLUMN = "Email"

  FIELDS = {
    "ISA Status"              => :isa_status,
    "Total Financed"          => :total_financed,
    "Repayment Percentage"    => :repayment_percentage,
    "Maximum Financed Amount" => :maximum_financed_amount,
    "Total Repaid So Far"     => :total_repaid_so_far,
    "Installments Paid"       => :installments_paid,
    "Max Installments"        => :max_installments,
    "Currency"                => :currency,
    "Institution"             => :institution
  }.freeze

  def initialize
    raise ConfigurationError, "GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON not set" unless ENV["GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON"].present?
    raise ConfigurationError, "GOOGLE_SHEETS_SPREADSHEET_ID not set"       unless ENV["GOOGLE_SHEETS_SPREADSHEET_ID"].present?
  end

  def fetch_for_email(email)
    rows = cached_rows
    row  = rows.find { |r| r[EMAIL_COLUMN]&.strip&.downcase == email.strip.downcase }
    raise NotFoundError, "No ISA data found for #{email}" unless row

    FIELDS.each_with_object({}) do |(col, key), result|
      result[key] = row[col]
    end
  end

  private

    def cached_rows
      Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { fetch_rows }
    end

    def fetch_rows
      range   = sheets_service.get_spreadsheet_values(ENV["GOOGLE_SHEETS_SPREADSHEET_ID"], "A:Z")
      values  = range.values || []
      headers = values.first || []
      values[1..].map { |row| headers.zip(row).to_h }
    rescue Google::Apis::Error => e
      raise Error, "Google Sheets API error: #{e.message}"
    end

    def sheets_service
      @sheets_service ||= begin
        credentials = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(ENV["GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON"]),
          scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
        )
        Google::Apis::SheetsV4::SheetsService.new.tap { |s| s.authorization = credentials }
      end
    end
end
