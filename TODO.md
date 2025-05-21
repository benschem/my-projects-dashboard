# TODO

## Setup and core app

### Initialize project

[X] bundle init
[X] Add to gems to Gemfile
[X] git init
[X] bundle install
[X] Folder structure
[X] README
[ ] Create Sinatra app (app.rb)
[ ] Mount from config.ru
[ ] Implement Basic Auth middleware
[ ] Store credentials in .env

### Data

[ ] Setup access for GitHub API
[ ] Decide what data exactly to pull
[ ] Write JSON caching script

### Views and UI

[ ] Index page
[ ] Show page

## Deployment

[ ] Set up reverse proxy so NGINX forwards to localhost:9292
[ ] Use systemd service to run bundle exec rackup
[ ] Configure ENV vars
[ ] Add logging
[ ] Use Logger class or just puts + timestamps
[ ] Log to file if needed

## Polish

[ ] Add error handling
[ ] If API rate limit hit or invalid response, log and skip
[ ] Ensure missing data doesn’t break UI

## Stretch Goals

[ ] Tag repos by status (WIP, Complete, Archive)
[ ] Show git commit graph with git log --graph
[ ] Track last personal commit (vs contributions)
[ ] Build a CLI to open projects locally
