# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'
require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_file(name, content = '')
    File.write("#{data_path}/#{name}", content)
  end

  def setup
    FileUtils.mkdir_p(data_path)
    create_file('about.txt', "It's beginning to feel a lot like Christmas")
    create_file('changes.txt', 'something something change is inevitable')
    create_file('history.txt', 'one death is a tragedy, a thousand is a statistic')
    create_file('changelog.md', "# Changelog

    ## Version 3.6.0

    * Avoid warnings running on Ruby 3.2+.

      Refs #721.

      *Jean Boussier*

    * Match fence char and length when matching closing fence in fenced code blocks.

      Fixes #208.")
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.txt'
    assert_includes last_response.body, 'history.txt'
    assert_includes last_response.body, 'changes.txt'
  end

  def test_viewing_text_document
    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'change is inevitable'
  end

  def test_handle_nonexistent_file
    get '/not_real.txt'
    assert_equal 302, last_response.status
    assert_equal 'not_real.txt does not exist.', last_request.session[:message]
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_nil last_request.session[:message]
  end

  def test_markdown_rendering
    get '/changelog.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Changelog</h1>'
  end

  def test_edit_file
    get '/about.txt/edit'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, '<button type="submit"'
  end

  def test_update_file
    post 'about.txt/edit', new_content: 'new content'

    assert_equal 302, last_response.status
    get last_response['Location']

    assert_includes last_response.body, 'about.txt successfully updated'

    get '/about.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'new content'
  end

  def test_create_file
    get '/new'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<h3><label>Add a new file:</label></h3>"

    post '/new', newfile: 'hello.txt'
    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_includes last_response.body, ">New File</a></p>"

    post '/new', newfile: 'hello'
    assert_includes last_response.body, "invalid file name"

    post '/new', newfile: ''
    assert_includes last_response.body, "a name is required"
  end

  def test_destroy_file
    post '/about.txt/destroy'
    assert_equal last_response.status, 302

    get last_response["Location"]
    assert_equal last_response.status, 200

    refute File.exist?('../test/data/about.txt')
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end
end