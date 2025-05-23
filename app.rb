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
    GithubClient.new(logger: settings.logger).fetch_repos_and_write_to_file
    settings.project_repository = ProjectRepository.new(logger: settings.logger)

    redirect '/', 303 # See Other
  end
end
