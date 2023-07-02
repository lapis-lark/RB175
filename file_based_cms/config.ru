require './cms'
require 'sinatra/reloader' if development?
run Sinatra::Application
