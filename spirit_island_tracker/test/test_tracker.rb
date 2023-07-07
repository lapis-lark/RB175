ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'
require_relative "../spirit_island_tracker"

class SpiritTrackerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_file(name, contents = '')
    File.write("#{data_path}/#{name}", YAML.dump(contents))
  end

  def setup
    FileUtils.mkdir_p(data_path)
    File.write("#{data_path}/test_file.rb", "")
    users = {"lapis"=>
    {Time.now =>
      {"win?"=>"true",
       "healthy_island?"=>"false",
       "score"=>"29",
       "adversary"=>"Scotland",
       "level"=>"4",
       "players"=>{"lapis"=>"Ocean's Hungry Grasp", "brenda"=>"Lightning's Swift Strike", "paul"=>"Bring of Dreams and Nightmares"},
       "date"=> Date.today.to_s}}}
    create_file("users.yml", users)
    
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<h3>Player Records:</h3>"
  end

end