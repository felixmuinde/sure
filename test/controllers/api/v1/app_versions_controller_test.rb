require "test_helper"

class Api::V1::AppVersionsControllerTest < ActionDispatch::IntegrationTest
  test "returns version and store_url when Play Store API succeeds" do
    Api::V1::AppVersionsController.any_instance.stubs(:fetch_play_store_version).returns(
      { version: "1.2.3", store_url: "https://play.google.com/store/apps/details?id=am.sure.mobile" }
    )
    Rails.cache.clear

    get "/api/v1/app_version"

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal "1.2.3", body["version"]
    assert_equal "https://play.google.com/store/apps/details?id=am.sure.mobile", body["store_url"]
  end

  test "returns 503 when Play Store API is unavailable" do
    Api::V1::AppVersionsController.any_instance.stubs(:fetch_play_store_version).returns(nil)
    Rails.cache.clear

    get "/api/v1/app_version"

    assert_response :service_unavailable
    body = JSON.parse(response.body)
    assert_equal "unavailable", body["error"]
  end

  test "does not require authentication" do
    Api::V1::AppVersionsController.any_instance.stubs(:fetch_play_store_version).returns(
      { version: "1.0.0", store_url: "https://play.google.com/store/apps/details?id=am.sure.mobile" }
    )
    Rails.cache.clear

    get "/api/v1/app_version"

    assert_response :ok
  end
end
