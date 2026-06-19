# frozen_string_literal: true

class InsightsController < ApplicationController
  def index
    loan_accounts = Current.family.accounts.visible.where(accountable_type: "Loan")
    @loan_account = loan_accounts.first

    if @loan_account
      @total_financed      = @loan_account.entries.sum(:amount).abs
      @repayments_count    = @loan_account.entries.count
      @total_repaid        = compute_total_repaid(@loan_account)
      @recent_transactions = @loan_account.entries.order(date: :desc).limit(10)
      @first_payment_due   = @loan_account.entries.minimum(:date)
      @monthly_instalment  = @loan_account.accountable.monthly_payment
      @repayment_streak    = compute_repayment_streak(@loan_account)
    end

    @max_instalments = 108
    @isa_status      = derive_isa_status(@loan_account)

    # ISA-specific fields from warehouse.ke_contacts — nil until warehouse sync is wired up.
    # Replace each nil with the real value once the data pipeline is in place.
    @instalment_due_date         = nil
    @months_in_arrears_principal = nil
    @months_in_arrears_admin     = nil
    @isa_percentage              = nil
    @is_employed_above_threshold = nil

    @breadcrumbs = [ [ "Home", root_path ], [ "Insights", nil ] ]
  end

  private

    def derive_isa_status(account)
      return nil unless account
      account.active? ? "repaying" : "contract_signed"
    end

    # Sums entries whose name suggests a repayment; falls back to all entries if none match.
    # Will be replaced by warehouse.all_student_payments WHERE payment_purpose ILIKE '%repayment%'.
    def compute_total_repaid(loan_account)
      repayment_sum = loan_account.entries
        .where("LOWER(name) LIKE ?", "%repayment%")
        .sum(:amount)
        .abs

      repayment_sum.positive? ? repayment_sum : loan_account.entries.sum(:amount).abs
    end

    # Counts consecutive calendar months (ending today) that have at least one entry.
    # Will be replaced by warehouse.all_student_payments filtered to repayment rows.
    def compute_repayment_streak(loan_account)
      months = loan_account.entries
        .pluck(:date)
        .map { |d| Date.new(d.year, d.month, 1) }
        .uniq
        .sort
        .reverse

      return 0 if months.empty?

      streak   = 0
      expected = Date.today.beginning_of_month
      months.each do |month|
        break unless month == expected
        streak  += 1
        expected -= 1.month
      end
      streak
    end
end
