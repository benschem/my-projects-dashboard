# frozen_string_literal: true

require 'logger'
require 'octokit'
require 'json'

# GITHUB REST API CLIENT
#
# Rate Limit: 5,000 requests per hour per token
# Resets: Every hour (on a rolling window)
#
# When the rate limit is exceeded you get a 403 Forbidden error - there are no charges
#
# With 50 repos, currently this code makes:
# 1 request (to get all repos)
# 50 repos × 1 requests (get repo languages) = 50 requests
# Total = 51 requests
# That's about ~1% of the hourly limit
class GithubClient
  attr_reader :logger

  def initialize(attributes = {}) # rubocop:disable Metrics/MethodLength
    @logger = attributes[:logger] ||= Logger.new($stdout)
    @output_file = attributes[:repos_file] || ENV['REPOS_DATA_FILE']
    # By default, Octokit does not timeout network requests
    # From docs - set a timeout in order to avoid Ruby’s Timeout module, which can kill your server
    Octokit.configure do |c|
      c.connection_options = {
        request: {
          open_timeout: 5,
          timeout: 5
        }
      }
      @client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
      @client.auto_paginate = true
    end
  end

  def fetch_repos_and_write_to_file
    repo_data = fetch_repo_data
    repos_with_languages = merge_languages_and_simplify(repo_data)
    repos = inset_total_lines(repos_with_languages)

    begin
      File.write(@output_file, JSON.pretty_generate(repos))
    rescue JSON::GeneratorError => e
      logger.error "JSON generation failed: #{e.message}"
    rescue SystemCallError, IOError => e
      logger.error "File write failed: #{e.message}"
    end
  end

  private

  def fetch_repo_data
    @client.repos
  rescue Octokit::Error => e
    logger.error "Unable to fetch repos: #{e.message}"
    []
  end

  def merge_languages_and_simplify(repos) # rubocop:disable Metrics/MethodLength
    Thread.report_on_exception = true if ENV['RACK_ENV'] != 'production'

    threads = repos.map do |repo|
      Thread.new do
        {
          name: repo.name,
          full_name: repo.full_name,
          url: repo.html_url,
          description: repo.description,
          languages: fetch_languages(repo)
        }
      end
    end

    threads.map(&:value)
  rescue ThreadError => e
    logger.error "Error joining threads while getting languages: #{e.message}"
  end

  def fetch_languages(repo)
    @client.languages(repo[:full_name]).to_h
  rescue Octokit::Error => e
    logger.error "Error fetching languages for #{repo[:full_name]}: #{e.message}"
    []
  end

  def inset_total_lines(repos)
    repos.each do |repo|
      repo[:total_lines] = repo[:languages].sum { |_, lines| lines }
    end
  end
end
