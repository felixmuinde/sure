require "test_helper"

class GoogleSignInTest < ActiveSupport::TestCase
  DUMMY_PAYLOAD = { "sub" => "user123", "iss" => "https://accounts.google.com", "aud" => "ios-client-id" }.freeze

  def stub_jwks(payload: DUMMY_PAYLOAD)
    jwks_response = stub(success?: true, body: { keys: [] }.to_json)
    Faraday.stubs(:get).with(GoogleSignIn::JWKS_URI).returns(jwks_response)
    JWT.stubs(:decode).returns([ payload ])
  end

  test "verifies a token whose audience matches the configured iOS client" do
    stub_jwks
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => "ios-client-id", "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => nil) do
      result = GoogleSignIn.verify!("token")
      assert_equal DUMMY_PAYLOAD, result
    end
  end

  test "accepts either the bare or https-prefixed Google issuer" do
    stub_jwks(payload: DUMMY_PAYLOAD.merge("iss" => "accounts.google.com"))
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => "ios-client-id", "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => nil) do
      result = GoogleSignIn.verify!("token")
      assert_equal "accounts.google.com", result["iss"]
    end
  end

  test "verifies a token whose audience matches the configured Android client" do
    stub_jwks(payload: DUMMY_PAYLOAD.merge("aud" => "android-client-id"))
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => nil, "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => "android-client-id") do
      result = GoogleSignIn.verify!("token")
      assert_equal "android-client-id", result["aud"]
    end
  end

  test "raises Error when no mobile client ID is configured" do
    stub_jwks
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => nil, "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => nil) do
      assert_raises(GoogleSignIn::Error) { GoogleSignIn.verify!("token") }
    end
  end

  test "raises Error when audience does not match either configured client" do
    stub_jwks(payload: DUMMY_PAYLOAD.merge("aud" => "someone-elses-app"))
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => "ios-client-id", "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => nil) do
      assert_raises(GoogleSignIn::Error) { GoogleSignIn.verify!("token") }
    end
  end

  test "raises Error when issuer is not a Google issuer" do
    stub_jwks(payload: DUMMY_PAYLOAD.merge("iss" => "https://evil.example.com"))
    with_env_overrides("GOOGLE_OAUTH_IOS_CLIENT_ID" => "ios-client-id", "GOOGLE_OAUTH_ANDROID_CLIENT_ID" => nil) do
      assert_raises(GoogleSignIn::Error) { GoogleSignIn.verify!("token") }
    end
  end
end
