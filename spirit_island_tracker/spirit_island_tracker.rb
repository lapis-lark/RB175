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

get '/' do
  
  @users = YAML.load(File.read(data_path + "/users.yml"), permitted_classes: [Time])
  erb :index
end


