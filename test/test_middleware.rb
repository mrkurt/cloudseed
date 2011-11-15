require "cloudseed_test"

require "rack/builder"
require "rack/test"

class TestMiddleware < CloudSeed::TestCase
  include Rack::Test::Methods

  class Echo
    def self.call(env)
      req = env.reject{|k,v| k.start_with?('rack.') }
      [200, {'Content-Type' => env['PATH_INFO'][1..-1]}, [req.inspect] ]
    end
  end
  def generic_app
    Rack::Builder.new do
      use CloudSeed::Middleware
      run Echo
    end
  end

  def app
    @app ||= generic_app
  end

  test "vary for text" do
    get "/text/plain"

    assert_equal "Accept-Encoding", last_response.headers['Vary']
  end

  CloudSeed::Middleware::CDN_ASSETS.each do |m|
    test "200 for CDN request of #{m}" do
      header "User-Agent", "Amazon CloudFront"
      get "/#{m}"

      assert_equal 200, last_response.status
      assert_not_nil last_response.headers['Expires']
      
      header "User-Agent", nil
    end
  end

  test "404 non-CDN content for CloudFront user agent" do
    header "User-Agent", "Amazon CloudFront"
    get "/text/html"

    assert_equal 404, last_response.status
    
    header "User-Agent", nil
  end

  ["javascript", "json", "atom+xml", "xml"].each do |f|
    test "vary for application/#{f}" do
      get "/application/#{f}"

      assert_equal "Accept-Encoding", last_response.headers['Vary']
    end
  end

  test "pre-extension-version" do
    get "/text/plain.v1234.txt"

    body = eval(last_response.body)
    assert_equal '1234', body['QUERY_STRING']
    assert_equal '/text/plain.txt', body['PATH_INFO']
  end
end
