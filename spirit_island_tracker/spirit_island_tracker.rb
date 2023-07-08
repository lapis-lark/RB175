require 'sinatra'
require 'sinatra/reloader' if development?
require "tilt/erubis"
require 'date'
require 'yaml'


def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def load_game_data
  YAML.load(File.read(data_path + "/games.yml"), permitted_classes: [Time])
end

def generate_game_id
  ids = @game_data.keys
  ids.empty? ? 0 : ids[-1] + 1
end

def get_user_games(user)
  user_games = @game_data.select { |_, data| data["players"].include?(user) }
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
  arr[0...-1].join(', ') + ", and #{arr[-1]}"
end

def display_spirits_vs_adversary(data)
  spirits = join_and(data["players"].values)
  "#{spirits} vs. #{data['adversary']} Level #{data['level']}"
end

before do
  @game_data = load_game_data
end

get '/' do
  erb :index
end


get '/users/:user' do |user|
  @user = user
  @user_games = get_user_games(user)
  erb :test_user_page
end

get '/users/:user/games/:game_id' do |user, game_id|
  @game_id = game_id.to_i
  @game = @game_data[@game_id]
  @user = user
  # return @users_data[@user][@game_id].inspect
  erb :game_data
end