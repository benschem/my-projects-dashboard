# frozen_string_literal: true

namespace :data do
  desc 'Manually manage project data'

  # rake data:refresh
  task :refresh do
    require_relative 'config/environment'
    require_relative './lib/github_client'

    puts 'Refreshing repo data from Github...'

    GithubClient.call

    puts 'Done.'
  end
end
