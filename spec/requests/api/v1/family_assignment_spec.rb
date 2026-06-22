# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Family Assignment', type: :request do
  let(:default_family) do
    Family.create!(
      name: 'Chancen Kenya',
      currency: 'KES',
      locale: 'en',
      date_format: '%m-%d-%Y',
      country: 'KE'
    )
  end

  let(:rwanda_family) do
    Family.create!(
      name: 'Chancen Rwanda',
      currency: 'RWF',
      locale: 'en',
      date_format: '%m-%d-%Y',
      country: 'RW'
    )
  end

  let(:user) do
    default_family.users.create!(
      email: 'student@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  let(:api_key) do
    key = ApiKey.generate_secure_key
    ApiKey.create!(
      user: user,
      name: 'API Docs Key',
      key: key,
      scopes: %w[read write],
      source: 'web'
    )
  end

  let(:'X-Api-Key') { api_key.plain_key }

  before { rwanda_family }

  path '/api/v1/family_assignment' do
    post 'Assign user to the family matching the given country code' do
      tags 'Family Assignment'
      security [ { apiKeyAuth: [] } ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          country_code: { type: :string, example: 'RW', description: 'ISO 3166-1 alpha-2 country code' }
        },
        required: [ 'country_code' ]
      }

      response '200', 'user assigned (or already in correct family)' do
        schema type: :object,
          properties: {
            family: {
              type: :object,
              properties: {
                id:       { type: :string, format: :uuid },
                name:     { type: :string },
                currency: { type: :string },
                locale:   { type: :string },
                country:  { type: :string }
              },
              required: %w[id currency locale country]
            }
          }

        let(:body) { { country_code: 'RW' } }
        run_test!
      end

      response '404', 'no family found for the given country code' do
        let(:body) { { country_code: 'XX' } }
        run_test!
      end

      response '422', 'country_code is missing' do
        let(:body) { {} }
        run_test!
      end

      response '401', 'authentication required' do
        let(:'X-Api-Key') { 'invalid' }
        let(:body) { { country_code: 'RW' } }
        run_test!
      end
    end
  end
end
