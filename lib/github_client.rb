# frozen_string_literal: true

require 'octokit'
require 'json'

# GITHUB CLIENT
class GithubClient
  # By default, Octokit does not timeout network requests
  # From docs - set a timeout in order to avoid Ruby’s Timeout module, which can kill your server
  Octokit.configure do |c|
    c.connection_options = {
      request: {
        open_timeout: 5,
        timeout: 5
      }
    }
  end

  def self.call
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    client.auto_paginate = true

    repos = fetch_repo_data(client.repos)
    threads = repos.map do |repo|
      Thread.new do
        repo[:languages] = get_languages(client, repo)
      end
    end
    threads.each(&:join)

    File.write('data/repos.json', JSON.pretty_generate(repos))
  end

  def self.fetch_repo_data(repos) # rubocop:disable Metrics/MethodLength
    repos.map do |repo|
      {
        name: repo.name,
        full_name: repo.full_name,
        url: repo.html_url,
        description: repo.description
      }
    end
  rescue Octokit::Error => e
    logger.error e
    []
  end

  def self.get_languages(client, repo)
    client.languages(repo[:full_name]).to_h
  rescue Octokit::Error
    logger.error e
    []
  end
end
#
# Rate Limit: 5,000 requests per hour per token
# Resets: Every hour (on a rolling window)
#
# When the rate limit is exceeded you get a 403 Forbidden error - there are no charges
# TODO: Handle 403 errors
#
# With 50 repos, currently this code makes:
# 1 request (to get all repos)
# 50 repos × 3 requests (languages, branches, commits) = 150 requests
# Total = 151 requests
# That's about ~3% of the hourly limit
