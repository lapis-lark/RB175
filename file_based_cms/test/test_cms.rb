ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "history.txt"
    assert_includes last_response.body, "changes.txt"
  end

  def test_viewing_text_document
    get '/about.txt'
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "soaring amidst the clouds"
  end

  def test_handle_nonexistent_file
    get '/not_real.txt'
    assert_equal 302, last_response.status
    assert_equal "not_real.txt does not exist.", last_request.session[:error]
    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_nil last_request.session[:error]
  end
end