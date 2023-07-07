=begin
  SETUP:
    Gemfile
    bundle install
    requires
    views
      layout.erb
      index.erb
  
=end

require 'sinatra'
require 'sinatra/contrib'
require "tilt/erubis"

get '/' do
  "Hello World!"
end
