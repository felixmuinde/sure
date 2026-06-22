# frozen_string_literal: true

require "test_helper"

class Api::V1::FamilyAssignmentControllerTest < ActionDispatch::IntegrationTest
  setup do
    # family_admin starts in dylan_family (the "default" family)
    @user = users(:family_admin)

    # Simulate a pre-existing "Chancen Rwanda" family
    @rwanda_family = families(:empty)
    @rwanda_family.update!(country: "RW")

    @user.api_keys.active.destroy_all
    @api_key = ApiKey.create!(
      user: @user,
      name: "Test Key",
      scopes: [ "read", "write" ],
      source: "web",
      display_key: "test_key_#{SecureRandom.hex(8)}"
    )
    Redis.new.del("api_rate_limit:#{@api_key.id}")
  end

  test "moves user to matching country family" do
    post api_v1_family_assignment_url,
      params: { country_code: "RW" },
      headers: api_headers(@api_key)

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal @rwanda_family.id, body.dig("family", "id")
    assert_equal "RW", body.dig("family", "country")
    assert_equal @rwanda_family.id, @user.reload.family_id
  end

  test "is a no-op when user is already in the matching family" do
    @user.update!(family_id: @rwanda_family.id)

    post api_v1_family_assignment_url,
      params: { country_code: "RW" },
      headers: api_headers(@api_key)

    assert_response :ok
    assert_equal @rwanda_family.id, @user.reload.family_id
  end

  test "returns not found for unknown country code" do
    post api_v1_family_assignment_url,
      params: { country_code: "XX" },
      headers: api_headers(@api_key)

    assert_response :not_found
  end

  test "returns unprocessable entity when country_code is missing" do
    post api_v1_family_assignment_url,
      headers: api_headers(@api_key)

    assert_response :unprocessable_entity
  end

  test "requires authentication" do
    post api_v1_family_assignment_url, params: { country_code: "RW" }

    assert_response :unauthorized
  end

  private

    def api_headers(api_key)
      { "X-Api-Key" => api_key.plain_key }
    end
end
