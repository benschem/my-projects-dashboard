# frozen_string_literal: true

require 'sinatra/base'
require 'json'

require_relative 'config/logger_setup'

# MY PROJECTS DASHBOARD
class MyProjectsDashboard < Sinatra::Base
  configure do
    set :logger, LoggerSetup.build(settings.environment)
  end

  helpers do
    def logger
      settings.logger
    end
  end

  # TODO: Some kind of cache system so this can be updated without restarting
  REPO_DATA = JSON.parse(File.read('data/repos.json'), symbolize_names: true)

  get '/' do
    @repos = REPO_DATA
    erb :index
  end

  post '/refresh' do
    system('ruby scripts/refresh.rb &')
    # Terminating a command with & means the shell executes the command asynchronously.
    # As in - do not wait for the command to finish before executing the next command.
    status 202
  end
end
