# frozen_string_literal: true

require 'sinatra/base'
require 'json'

require_relative 'config/logger_setup'
require_relative 'lib/github_client'
require_relative 'projects/project_repository'

# MY PROJECTS DASHBOARD
class MyProjectsDashboard < Sinatra::Base
  configure do
    set :logger, LoggerSetup.build(settings.environment)
    set :project_repository, ProjectRepository.new(logger: settings.logger)
  end

  helpers do
    def logger
      settings.logger
    end

    def projects
      settings.project_repository
    end
  end

  get '/' do
    @projects = projects.all
    erb :index
  end

  post '/refresh' do
    system('ruby scripts/refresh.rb &')
    # Terminating a command with & means the shell executes the command asynchronously.
    # As in - do not wait for the command to finish before executing the next command.
    status 202
  end
end
