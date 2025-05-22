# frozen_string_literal: true

require 'octokit'
require 'json'

# By default, Octokit does not timeout network requests.
# From docs - set a timeout in order to avoid Ruby’s Timeout module, which can hose your server.
Octokit.configure do |c|
  c.connection_options = {
    request: {
      open_timeout: 5,
      timeout: 5
    }
  }
end

# ------- Github REST API Rate Limits -------
# Limit: 5,000 requests per hour per token
# Resets: Every hour (on a rolling window)
#
# When the rate limit is exceeded you get a 403 Forbidden error - there are no charges
#
# I've got about 50 repos:
#
# 1 (get all repos)
# 50 × 3 = 150 (languages, branches, commits)
# Total = 151 requests
# That's about ~3% of the hourly limit

# This needs refactoring as it takes 2+ minutes to finish
# Consider using parallel threads or GraphQL
def call
  client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  client.auto_paginate = true

  begin
    repos = client.repos # 1 request

    data = repos.map do |repo|
      {
        name: repo.name,
        owner: repo.owner.login,
        url: repo.html_url,
        private: repo.private,
        description: repo.description,
        collaborators: repo.collaborators,
        languages: client.languages(repo.full_name).to_h, # 1 request
        branches: client.branches(repo.full_name).map(&:name), # 1 request
        commits: get_commit_messages_by_me(client, repo)
      }
    end
  rescue Octokit::Error => e
    if e.response
      # This should log
      puts "Error! Status: #{e.response.status}. Message: #{e.response.data.message}"
    end
    # This should log
    puts e
  end

  File.write('data/repos.json', JSON.pretty_generate(data))
end

def get_commit_messages_by_me(client, repo)
  # 1 request
  client.commits(repo.full_name).filter_map do |commit|
    if commit[:commit][:committer][:email] == ENV['GITHUB_EMAIL'] # only care about comits I made
      commit[:commit][:message]
    end
  end
rescue Octokit::Conflict # raised if no commits
  []
end
