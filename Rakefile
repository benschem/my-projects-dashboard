# frozen_string_literal: true

namespace :data do
  desc 'Manually manage project data'

  # rake data:refresh
  task :refresh do
    require_relative 'config/environment'
    require_relative './lib/github_client'

    data_file = ENV['REPOS_FILE'] || 'data/repos.json'
    file_last_updated = File.mtime(data_file)

    puts 'Refreshing repo data from Github...'

    GithubClient.new.fetch_repos_and_write_to_file

    if file_last_updated == File.mtime(data_file)
      puts 'Unable to update repo data.'
    else
      puts 'Updated repo data.'
    end
  end
end
