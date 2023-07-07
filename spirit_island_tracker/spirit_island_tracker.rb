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

def load_users_data
  YAML.load(File.read(data_path + "/users.yml"), permitted_classes: [Time])
end

def generate_game_id
  users_data = load_users_data
  ids =[]
  
  users_data.each { |user| ids << users_data[user].keys }
  return 0 if ids.empty?
  ids.map.sort[-1] + 1
end

def display_win_information(user)
  user_data = load_users_data[user]
  games = user_data.keys.size
  wins = user_data.select { |k, _| user_data[k]["win?"] == "true" }.size
  losses = games - wins

  "#{games} game(s) played (#{wins} win(s), #{losses} losses)"
  # user_data.inspect
end

before do
  @users_data = load_users_data
end

get '/' do
  erb :index
end


get '/users/:user' do |user|
  @user = user
  erb :test_user_page
end

get '/users/:user/games/:game_id' do |user, game_id|
  @game_id = game_id.to_i
  @user = user
  # return @users_data[@user][@game_id].inspect
  erb :game_data
end