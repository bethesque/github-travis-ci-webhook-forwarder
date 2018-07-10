require 'net/http'
require 'json'
require 'openssl'

class WebhookProxy
  def call(env)
    return [200, {'Content-Type' => 'text/html'}, ["Hello world"]] if env["REQUEST_METHOD"] != "POST"

    request_body = env['rack.input'] ? env['rack.input'].read : ""
    verify_signature(request_body, env)
    uri = URI.parse("https://api.travis-ci.org/repo/#{ENV.fetch('REPO_SLUG')}/requests")

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request["Travis-API-Version"] = "3"
    request["Authorization"] = "token #{ENV['GITHUB_ACCESS_TOKEN']}"

    body = {
     "request" => {
     "message" => ENV.fetch('COMMIT_MESSAGE'),
     "branch" => "master",
     "config" => {
       "script" => ENV.fetch('BUILD_SCRIPT')
      }
    }}

    request.body = body.to_json
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    [200, {}, []]
  rescue StandardError => e
    puts e.message
    puts e.backtrace
    [500, {}, [e.message]]
  end

  def verify_signature(request_body, env)
    return true
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV.fetch('GITHUB_SECRET'), request_body)
    raise "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, env.fetch('HTTP_X_HUB_SIGNATURE'))
  end
end

run WebhookProxy.new
