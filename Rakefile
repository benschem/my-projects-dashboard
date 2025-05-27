# frozen_string_literal: true

namespace :repos do
  desc 'Manually manage project data'

  # rake repos:refresh
  task :to_json do
    require_relative 'config/environment'
    require_relative './lib/github_repo_exporter'

    data_file = ENV['REPOS_DATA_FILE'] || 'data/repos.json'
    file_last_updated = File.mtime(data_file)

    puts 'Pulling repo data from Github API...'

    GithubRepoExporter.new.repos_to_file

    if file_last_updated == File.mtime(data_file)
      puts 'Error: file was not written to: `/data/repos.json`'
    else
      puts 'Written GitHub repo data to file: `/data/repos.json`'
    end
  end
end
