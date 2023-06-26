require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

get "/" do
  @entries = Dir.entries("public").sort[2..-1]
  @entries.reverse! if params[:reverse] == 'true'
  erb :home
end