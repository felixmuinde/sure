module InsightsHelper
  PURPOSE_LABELS = [
    [ "repayment",    "Repayment" ],
    [ "admin",        "Admin Fee" ],
    [ "commitment",   "Commitment Fee" ],
    [ "application",  "Application Fee" ],
    [ "drop",         "Drop-out Fee" ],
    [ "contribution", "Contribution Fee" ]
  ].freeze

  def payment_purpose_label(name)
    return t("insights.recent_transactions.purpose_default") if name.blank?
    matched = PURPOSE_LABELS.find { |keyword, _| name.downcase.include?(keyword) }
    matched ? matched[1] : t("insights.recent_transactions.purpose_default")
  end
end
