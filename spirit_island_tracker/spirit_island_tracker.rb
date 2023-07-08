require 'sinatra'
require 'sinatra/reloader' if development?
require "tilt/erubis"
require 'date'
require 'yaml'
require 'sinatra/content_for'


def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def load_game_data
  YAML.load(File.read(data_path + "/games.yml"))
end

def generate_game_id
  ids = @game_data.keys
  ids.empty? ? 0 : ids[-1] + 1
end

def get_user_games(user)
  user_games = @game_data.select { |_, data| data["players"].include?(user) }
end

def get_users
  YAML.load(File.read(data_path + "/users.yml"))
end

def display_win_information(user)
  user_games = get_user_games(user)
  total_games = user_games.keys.size
  wins = user_games.select { |_, data| data["win?"] == "true" }.size
  losses = total_games - wins

  "#{total_games} game(s) played (#{wins} win(s), #{losses} losses)"
  # user_data.inspect
end

def join_and(arr)
  return arr[0] if arr.size < 2
  arr[0...-1].join(', ') + " and #{arr[-1]}"
end

def display_spirits_vs_adversary(data)
  players = join_and(data["players"].keys)
  "#{players} vs. #{data['adversary']} Level #{data['level']}"
end

=begin
  IN: hash of player/spirit numbers and players/spirits
  OUT: player keys spirit values hash
  EX: {spirit0 => 'branch', player0 => 'lapis'}
    => {'lapis' => 'branch'}

  ALGO:
    separate all spirit/player pairs
    remove pairs with empty value
    size/ 2.times |i|
      new_hash[hash["player#{i}"]] = hash["spirit#{i}"]



=end



def cleaned_record
  spir_play, cleaned = params.partition do |k, _|
    k.match?('spirit') || k.match?('player') # could be improved, fine for now
  end

  cleaned = cleaned.to_h

  spir_play.reject! { |_, v| v == 'empty' }
  spir_play = spir_play.to_h
  
  players = {}
  (spir_play.size / 2).times do |i|
    players[spir_play["player#{i}"]] = spir_play["spirit#{i}"]
  end
  cleaned["players"] = players
  cleaned
end

before do
  @game_data = load_game_data
  @users = get_users
end

get '/' do
  erb :index
end


get '/users/:user' do |user|
  @user = user
  @user_games = get_user_games(user)
  erb :test_user_page
end

get '/games/:game_id' do |game_id|
  @game_id = game_id.to_i
  @game = @game_data[@game_id]
  # return @users_data[@user][@game_id].inspect
  erb :game_data
end

get '/new_record' do
  @spirits = ['[empty]', "Shadows Flicker like Flame", "Starlight Seeks its Form", "Thunderspeaker", "Sharp Fangs Behind the Leaves", "Lure of the Deep Wilderness", "Volcano Looming High", "Grinning Trickster Stirs Up Trouble", "A Spread of Rampant Green", "River Surges in Sunlight", "Bringer of Dreams and Nightmares"]
  @adversaries = %w(none Brandenburg-Prussia England France Russia Sweden Scotland Habsburg)  
  erb :new_record
end

post '/new_record' do 
  game_id = generate_game_id
  @game_data[game_id] = cleaned_record
  File.write(data_path + "/games.yml", YAML.dump(@game_data))
  redirect '/'
end