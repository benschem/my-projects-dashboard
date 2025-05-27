# frozen_string_literal: true

require 'sinatra/base'
require 'json'

require_relative 'config/logger_setup'
require_relative 'lib/github_repo_exporter'
require_relative 'projects/project_repository'

require_relative 'helpers/filter_helpers'
require_relative 'helpers/logger_helpers'
require_relative 'helpers/project_helpers'
require_relative 'helpers/sort_helpers'

# MY PROJECTS DASHBOARD
class MyProjectsDashboard < Sinatra::Base
  helpers FilterHelpers
  helpers LoggerHelpers
  helpers ProjectHelpers
  helpers SortHelpers

  configure do
    set :logger, LoggerSetup.build(settings.environment)

    set :github_repo_exporter, GithubRepoExporter.new(logger: settings.logger)

    # Only hit the Github API on boot in production
    # In development use `rake repos:to_json` to create and refresh the data file
    # Or the `/refresh`` endpoint
    settings.github_repo_exporter.repos_to_file if settings.environment == :production

    set :projects, ProjectRepository.new(logger: settings.logger)
  end

  get '/' do
    filters_by_category = build_filters(params)

    filtered_projects = projects.all.select do |project|
      filters_by_category.all? do |category, filters|
        next true unless filters&.any?

        project_matches_filter?(category, filters, project)
      end
    end

    @projects = sorted_projects(filtered_projects, params)

    erb :index
  end

  post '/refresh' do
    github.repos_to_file
    reload_projects!

    redirect '/', 303 # See Other
  end
end
