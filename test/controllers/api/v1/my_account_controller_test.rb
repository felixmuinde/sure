# frozen_string_literal: true

require "test_helper"

class Api::V1::MyAccountControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:family_admin)
    @user.api_keys.active.destroy_all

    @api_key = ApiKey.create!(
      user: @user,
      name: "Test Read Key",
      scopes: [ "read" ],
      display_key: "test_ro_#{SecureRandom.hex(8)}",
      source: "mobile"
    )

    Redis.new.del("api_rate_limit:#{@api_key.id}")

    # Reset Metabase settings before each test
    Setting.metabase_url = "https://metabase.example.com"
    Setting.metabase_api_key = "test-key" # pipelock:ignore
    Setting.metabase_student_question_id = "123"
    Setting.metabase_email_param = "email"
  end

  teardown do
    Setting.metabase_url = nil
    Setting.metabase_api_key = nil
    Setting.metabase_student_question_id = nil
    Setting.metabase_email_param = nil
  end

  test "returns 401 without auth" do
    get "/api/v1/my_account"
    assert_response :unauthorized
  end

  test "returns 503 when Metabase not configured" do
    Setting.metabase_url = nil
    Setting.metabase_api_key = nil
    Setting.metabase_student_question_id = nil

    get "/api/v1/my_account", headers: api_headers
    assert_response :service_unavailable

    body = JSON.parse(response.body)
    assert_equal "not_configured", body["error"]
  end

  test "returns 404 when student not found in Metabase" do
    Provider::MetabaseStudentAccount.any_instance.stubs(:find_by_email).returns(nil)

    get "/api/v1/my_account", headers: api_headers
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_equal "not_found", body["error"]
  end

  test "returns student account data when found" do
    account = Provider::MetabaseStudentAccount::StudentAccountData.new(
      email: @user.email,
      status: "repaying",
      total_financed: 268240.0,
      repayments_received: 45000.0,
      max_amount: 300000.0,
      installments_paid: 9,
      max_installments: 108,
      currency: "KES"
    )
    Provider::MetabaseStudentAccount.any_instance.stubs(:find_by_email).returns(account)

    get "/api/v1/my_account", headers: api_headers
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @user.email, body["email"]
    assert_equal "repaying",  body["status"]
    assert_equal 268240.0,    body["total_financed"]
    assert_equal 45000.0,     body["repayments_received"]
    assert_equal 300000.0,    body["max_amount"]
    assert_equal 9,           body["installments_paid"]
    assert_equal 108,         body["max_installments"]
    assert_equal "KES",       body["currency"]
  end

  test "returns 502 on provider error" do
    Provider::MetabaseStudentAccount.any_instance.stubs(:find_by_email)
      .raises(Provider::MetabaseStudentAccount::Error, "connection refused")

    get "/api/v1/my_account", headers: api_headers
    assert_response :bad_gateway

    body = JSON.parse(response.body)
    assert_equal "provider_error", body["error"]
  end

  private

    def api_headers
      { "X-Api-Key" => @api_key.display_key }
    end
end
