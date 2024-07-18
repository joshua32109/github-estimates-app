
require 'sinatra'
require 'octokit'
require 'dotenv/load'
require 'smee_client'
require 'openssl'
require 'jwt'

class GitHubEstimateApp < Sinatra::Base
  configure do
    set :show_exceptions, :after_handler
  end

  # Verify the webhook signature
  def verify_signature(payload_body)
    secret = ENV['WEBHOOK_SECRET']
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, payload_body)
    return halt 401 unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
  end

  # Get the installation token
  def get_installation_client(installation_id)
    private_pem = File.read(ENV['GITHUB_PRIVATE_KEY_PATH'])
    payload = {
      iat: Time.now.to_i,
      exp: Time.now.to_i + (10 * 60),
      iss: ENV['GITHUB_APP_IDENTIFIER']
    }
    jwt = JWT.encode(payload, private_pem, 'RS256')
    client = Octokit::Client.new(bearer_token: jwt)
    token = client.create_app_installation_access_token(installation_id)[:token]
    Octokit::Client.new(access_token: token)
  end

  post '/payload' do
    request.body.rewind
    payload_body = request.body.read
    verify_signature(payload_body)

    event = JSON.parse(payload_body)
    action = event['action']
    issue = event['issue']
    repo = event['repository']['full_name']
    installation_id = event['installation']['id']

    if action == 'opened'
      estimate_pattern = /Estimate:\s*\d+\s*days/i
      unless estimate_pattern.match?(issue['body'])
        client = get_installation_client(installation_id)
        client.add_comment(repo, issue['number'], "Please provide an estimate in the format 'Estimate: X days'.")
      end
    end

    status 200
  end

  run! if app_file == $0
end
