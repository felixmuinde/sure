module GoogleSignIn
  Error = Class.new(StandardError)

  JWKS_URI = "https://www.googleapis.com/oauth2/v3/certs".freeze
  # Google issues both forms across libraries/versions; accept either.
  ISSUERS = [ "accounts.google.com", "https://accounts.google.com" ].freeze

  def self.verify!(identity_token)
    jwks_response = Faraday.get(JWKS_URI)
    raise Error, "Failed to fetch Google public keys" unless jwks_response.success?

    jwks = JWT::JWK::Set.new(JSON.parse(jwks_response.body))
    payload, = JWT.decode(
      identity_token,
      nil,
      true,
      algorithms: %w[RS256],
      jwks: jwks
    )

    raise Error, "Invalid issuer" unless ISSUERS.include?(payload["iss"])

    # Native sign-in issues a token per platform client (iOS/Android), unlike
    # Apple's single bundle ID — accept either configured mobile client ID.
    client_ids = [
      ENV["GOOGLE_OAUTH_IOS_CLIENT_ID"],
      ENV["GOOGLE_OAUTH_ANDROID_CLIENT_ID"]
    ].compact_blank
    raise Error, "Google mobile sign-in is not configured" if client_ids.empty?
    raise Error, "Invalid audience" unless client_ids.include?(payload["aud"])

    payload
  rescue JWT::DecodeError => e
    raise Error, e.message
  end
end
