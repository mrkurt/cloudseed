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
