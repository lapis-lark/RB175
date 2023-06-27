require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'
require 'yaml'

helpers do
  def count_users
    @data.keys.size
  end

  def count_interests
    memo = 0
    @data.keys.each { |k, v| memo += @data[k][:interests].size }
    memo
  end
end

before do
  @data = YAML.load_file('data/users.yml')
end

get '/' do
  redirect '/users'
end

get '/users' do
  @title = 'users'
  erb :users
end

get '/data/users/:name' do
  @user = params[:name].to_sym #? add in verifying method
  @title = @user
  @interests = @data[@user][:interests]
  @email = @data[@user][:email]
  erb :profile
end