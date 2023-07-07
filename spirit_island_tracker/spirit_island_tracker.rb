=begin
  Data structure for spirit island results

  {users
    {games
      win/lose: 
      adversary:
      level: (0 unless adversary selected)
      ...
    }

  }







=end

require 'sinatra'
require 'sinatra/contrib'
require "tilt/erubis"
require 'date'

get '/' do
  erb :index
end


