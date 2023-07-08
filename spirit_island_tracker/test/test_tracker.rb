# ENV['RACK_ENV'] = 'test'

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

  def generate_date
    year = (2018..2023).to_a.sample
    month = (1..12).to_a.sample
    day = (1..28).to_a.sample

    "#{year}-#{month}-#{day}"
  end

  def setup
=begin
    FileUtils.mkdir_p(data_path)
    File.write("#{data_path}/test_file.rb", "")
    players = {"lapis"=>
    {Time.now =>
      {"win?"=>"true",
       "healthy_island?"=>"false",
       "score"=>"29",
       "adversary"=>"Scotland",
       "level"=>"4",
       "players"=>{"lapis"=>"Ocean's Hungry Grasp", "brenda"=>"Lightning's Swift Strike", "paul"=>"Bring of Dreams and Nightmares"},
       "date"=> Date.today.to_s}}}
    create_file("players.yml", players)
=end
  end


  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<h2>Player Records:</h2>"
  end

  def test_add_record
    players = %w(lapis brenda paul spencer walker man marcus julian flavia amy)
    spirits = ["Shadows Flicker like Flame", "Starlight Seeks its Form", "Thunderspeaker", "Sharp Fangs Behind the Leaves", "Lure of the Deep Wilderness", "Volcano Looming High", "Grinning Trickster Stirs Up Trouble", "A Spread of Rampant Green", "River Surges in Sunlight", "Bringer of Dreams and Nightmares"]
    adversaries = %w(Brandenburg-Prussia England France Russia Sweden Scotland Habsburg)  
    100.times do 
      post '/new_record', score: (10..60).to_a.sample, player0: players.sample, spirit0: spirits.sample, player1: players.sample, spirit1: spirits.sample, player2: players.sample, spirit2: spirits.sample, adversary: adversaries.sample, level: (0..6).to_a.sample, win?: [true, false].sample, healthy_island?: [true, false].sample, date: generate_date
    end
  end

end