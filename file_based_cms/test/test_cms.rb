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
    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "can come into existence"
  end

  def test_handle_nonexistent_file
    get '/not_real.txt'
    assert_equal 302, last_response.status
    assert_equal "not_real.txt does not exist.", last_request.session[:error]
    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_nil last_request.session[:error]
  end

  def test_markdown_rendering
    get '/changelog.md'
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Changelog</h1>"
  end

  def test_edit_file
    get '/about.txt/edit'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_update_file
    post 'about.txt/edit', new_content: "new content"

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_includes last_response.body,  "about.txt successfully updated"

    get '/about.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end