# frozen_string_literal: true

require 'sinatra'
require 'json'

# Require Bundler and set up the load paths
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || :development)

# Load environment variables
require 'dotenv'
Dotenv.load

use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  username == ENV['DASHBOARD_USER'] && password == ENV['DASHBOARD_PASSWORD']
end

# use Rack::Deflater
# use Rack::Logger

# TODO: maybe don't read from the file on every request?
get '/' do
  # logger.info "Serving dashboard"
  file_contents = File.read('data/repos.json')
  @repos = JSON.parse(file_contents, symbolize_names: true)
  erb :index
end

post '/refresh' do
  system('ruby scripts/refresh.rb &')
  # Terminating a command with & means the shell executes the command asynchronously.
  # As in - do not wait for the command to finish before executing the next command.
  status 202
end
