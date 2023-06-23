require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

get "/" do
  @title = "Sherlock Holmes"
  @toc = File.readlines("data/toc.txt")
  erb :home
end
