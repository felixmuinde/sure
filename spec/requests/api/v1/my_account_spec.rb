# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 My Account', type: :request do
  let(:family) do
    Family.create!(
      name: 'API Family',
      currency: 'KES',
      locale: 'en',
      date_format: '%m-%d-%Y'
    )
  end

  let(:user) do
    family.users.create!(
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
      scopes: %w[read_write],
      source: 'web'
    )
  end

  let(:'X-Api-Key') { api_key.plain_key }

  path '/api/v1/my_account' do
    get 'Show student account data' do
      tags 'My Account'
      description 'Returns Chancen ISA student account data for the authenticated user, fetched from Metabase.'
      security [ { apiKeyAuth: [] } ]
      produces 'application/json'

      response '200', 'student account returned' do
        schema '$ref' => '#/components/schemas/StudentAccount'

        before do
          allow_any_instance_of(Provider::MetabaseStudentAccount).to receive(:find_by_email).and_return(
            Provider::MetabaseStudentAccount::StudentAccountData.new(
              email: 'student@example.com',
              status: 'repaying',
              total_financed: 268240.0,
              repayments_received: 45000.0,
              max_amount: 300000.0,
              installments_paid: 9,
              max_installments: 108,
              currency: 'KES'
            )
          )
          Setting.metabase_url = 'https://metabase.example.com'
          Setting.metabase_api_key = 'test-key' # pipelock:ignore
          Setting.metabase_student_question_id = '123'
        end

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:'X-Api-Key') { 'invalid-key' }

        run_test!
      end

      response '503', 'Metabase not configured' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        before do
          Setting.metabase_url = nil
          Setting.metabase_api_key = nil
          Setting.metabase_student_question_id = nil
        end

        run_test!
      end

      response '404', 'student not found' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        before do
          allow_any_instance_of(Provider::MetabaseStudentAccount).to receive(:find_by_email).and_return(nil)
          Setting.metabase_url = 'https://metabase.example.com'
          Setting.metabase_api_key = 'test-key' # pipelock:ignore
          Setting.metabase_student_question_id = '123'
        end

        run_test!
      end
    end
  end
end
