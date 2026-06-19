class InsightsController < ApplicationController
  def index
    loan_accounts = Current.family.accounts.visible.where(accountable_type: "Loan")

    @loan_account = loan_accounts.first

    if @loan_account
      @total_financed   = @loan_account.entries.sum(:amount).abs
      @repayments_count = @loan_account.entries.count
    end

    @max_instalments = 108
    @isa_status      = derive_isa_status(@loan_account)

    @breadcrumbs = [ [ "Home", root_path ], [ "Insights", nil ] ]
  end

  private

    def derive_isa_status(account)
      return nil unless account
      account.active? ? "repaying" : "contract_signed"
    end
end
