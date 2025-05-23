# TODO

## Setup and core app

### Initialize project

[X] bundle init
[X] Add to gems to Gemfile
[X] git init
[X] bundle install
[X] Folder structure
[X] README
[X] Create Sinatra app (app.rb)
[X] Mount from config.ru
[X] Implement Basic Auth middleware
[X] Store credentials in .env

### Data

[X] Setup access for GitHub API
[X] Decide what data exactly to pull
[X] Write a script to fetch the repo data
[X] Write a Rake task to manually fetch the data

### Views and UI

[X] Index page
[ ] Nice styling
[ ] Filter
[ ] Search

## Deployment

[ ] Set up reverse proxy so NGINX forwards to localhost:9292
[ ] Use systemd service to run bundle exec rackup
[X] Configure ENV vars
[X] Add logging
[X] Log to file in production

## Polish

[X] Add error handling
[X] If API rate limit hit or invalid response, log and skip
[X] Ensure missing data doesn’t break UI

## Stretch Goals

[X] Add project meta data that saves to separate JSON - use ids to link them
[X] Tag repos by status (WIP, Complete, Archive)
