## SPIRIT ISLAND TRACKER

### Features:
- create profiles for different users
- pages for each user:
  - add results of a new game (only user)
    - score
    - win/lose
    - spirits played with
    - adversary
    - adversary level
    - healthy/unhealthy island
    - date played (added automatically?)
  - view individual game
  - view statistics for all games played
  - edit game info (only user)
  - index of all users linking to their statistics page



REQUIREMENTS:
  Make an index page listing all users
    Link to the user page


STEPS:
  get '/'
    Supply all user information to index.erb
    iterate over users, print each, link to user page

  get '/users/:name'
    blank for now

  # To look up later
   - what does Rack::Test include?
     - uses?


### user_page
  - games played (wins / losses)
  - best game (highest score && win? == true)
  - list of all games
  - most played spirit (x times)
  - least played spirits (x times)
  


### edit page
  - input fields for:
    - win? (radio?)
    - healthy_island? (radio?)
    - score (integer)
    - adversary (drop down)
    - level (drop down)
    - players (drop down, add new possible, 1-6)
    - spirit for each player (drop down)
    - date (yyyy-mm-dd format text field)