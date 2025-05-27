# frozen_string_literal: true

require 'logger'
require 'octokit'
require 'json'

# GITHUB REPO EXPORTER
#
# Creates instances of an Octokit client to make calls to the GitHub REST API v3
# Fetches certain data about each repo
# Exports the repo data to JSON
# Writes JSON to file cache
#
# API Rate Limit: 5,000 requests per hour per token
# Resets: Every hour (on a rolling window)
#
# When the rate limit is exceeded you get a 403 Forbidden error - there are no charges
#
# With 50 repos, currently this code makes:
# 1 request (to get all repos)
# 50 repos × 1 requests (get repo languages) = 50 requests
# Total = 51 requests
# That's about ~1% of the hourly limit
class GithubRepoExporter # rubocop:disable Metrics/ClassLength
  attr_reader :logger

  def initialize(attributes = {})
    @logger = attributes[:logger] ||= Logger.new($stdout)
    @output_file = attributes[:repos_file] || ENV['REPOS_DATA_FILE']
    raise ArgumentError, 'Output file path not set' unless @output_file

    # By default, Octokit does not timeout network requests
    # From docs - set a timeout in order to avoid Ruby’s Timeout module, which can kill your server
    Octokit.configure do |c|
      c.connection_options = {
        request: {
          open_timeout: 5, timeout: 5
        }
      }
    end
  end

  def repos_to_file
    repo_data = fetch_repo_data
    repos = build_repos(repo_data)
    write_to_file(repos)
  end

  private

  def client
    Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN']).tap do |client|
      client.auto_paginate = true
    end
  end

  def fetch_repo_data
    with_retries { client.repos }
  rescue Octokit::Error => e
    logger.error "Unable to fetch repos: #{e.class} - #{e.message}"
    []
  end

  def write_to_file(repos)
    File.write(@output_file, JSON.pretty_generate(repos))
  rescue JSON::GeneratorError => e
    logger.error "JSON generation failed while trying to write repos to file: #{e.class} - #{e.message}"
  rescue SystemCallError, IOError => e
    logger.error "File write failed while trying to write repos to file: #{e.class} - #{e.message}"
  end

  def build_repos(repo_data) # rubocop:disable Metrics/MethodLength
    language_data = fetch_language_data(repo_data)
    repo_data.zip(language_data || []).map do |repo, languages|
      {
        name: repo.name,
        full_name: repo.full_name,
        url: repo.html_url,
        description: repo.description,
        created_at: repo.created_at,
        pushed_at: repo.pushed_at,
        languages: languages || {},
        total_lines: (languages || {}).sum { |_, lines| lines }
      }
    end
  end

  def fetch_language_data(repos, pool_size: 5)
    queue = Queue.new
    # Add all repos to queue with their index to preserve order
    repos.each_with_index { |repo, i| queue << [i, repo] }

    # Placeholder for language data, matched by index
    results = Array.new(repos.size)

    workers = pool_size.times.map do
      Thread.new do
        # Create separate Octokit client per thread (not thread-safe to share)
        client = self.client

        loop do
          begin
            # Non-blocking pop, raises ThreadError when empty
            index, repo = queue.pop(true)
          rescue ThreadError
            break # queue is empty, thread is done
          end
          # Fetch language data and store in correct index
          results[index] = fetch_languages(repo, client)
        end
      end
    end

    begin
      # Wait for all threads to finish
      workers.each(&:join)
    rescue ThreadError => e
      logger.error "Error joining threads while getting languages: #{e.class} - #{e.message}"
      return []
    end

    results
  end

  def fetch_languages(repo, client)
    with_retries { client.languages(repo.full_name).to_h }
  rescue Octokit::Error => e
    logger.error "Github API error while fetching languages #{e.class} - #{e.message}"
    {}
  rescue StandardError => e
    logger.error("Unexpected error while fetching languages #{e.class} - #{e.message}")
    {}
  end

  def with_retries(limit: 3, delay: 1) # rubocop:disable Metrics/MethodLength
    attempts = 0
    begin
      yield
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      attempts += 1
      if attempts <= limit
        logger.warn("Retrying due to network error: #{e.class} - #{e.message} (attempt #{attempts}/#{limit})")
        sleep delay
        retry
      else
        logger.error("Failed after #{limit} attempts: #{e.class} - #{e.message}")
        {}
      end
    end
  end
end
