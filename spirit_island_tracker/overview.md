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