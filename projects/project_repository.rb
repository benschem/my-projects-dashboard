# frozen_string_literal: true

require 'logger'
require_relative 'project'

# Project
class ProjectRepository
  attr_reader :logger

  def initialize(attributes = {})
    @repos_data_file = attributes[:repos_file] || ENV['REPOS_DATA_FILE']
    @metadata_file = attributes[:metadata_file] || ENV['REPOS_METADATA_FILE']
    @logger = attributes[:logger] || Logger.new($stdout)
    @projects = []

    load_projects if File.exist?(@repos_data_file)
  end

  def all
    logger.warn('Unable to retrieve projects') if @projects.empty?

    @projects
  end

  def find(id)
    project = @projects.find { |project| project.id == id }
    logger.error "Unable to find Project with id: #{id}" if project.nil?

    project
  end

  def update(attributes)
    project = find(attributes[:id])
    logger.error "Unable to update Project with id: #{attributes[:id]}" if project.nil?
    return unless project

    project.status = attributes[:status]
    project.priority = attributes[:priority]
    project.type = attributes[:type]

    write_metadata_to_file
  end

  private

  def load_projects
    repos = parse_json(@repos_data_file)
    repos_metadata = File.exist?(@metadata_file) ? parse_json(@metadata_file) : []

    repos.each do |repo|
      project_metadata = find_metadata(repo, repos_metadata)
      project = build_project(repo, project_metadata)
      @projects << project
    end

    write_metadata_to_file unless File.exist?(@metadata_file)
  end

  def parse_json(file)
    JSON.parse(File.read(file), symbolize_names: true)
  rescue JSON::ParserError => e
    logger.error("Failed to parse #{file}: #{e.message}")
    []
  end

  def build_project(repo, metadata)
    %i[status priority type motivation].each do |key|
      repo[key] = metadata&.dig(key)
    end

    Project.new(repo)
  end

  def find_metadata(repo, repos_metadata)
    metadata = repos_metadata.find { |metadata| metadata[:full_name] == repo[:full_name] }
    logger.warn "Metadata missing for #{repo[:full_name]} - only expected on first launch" if metadata.nil?

    metadata
  end

  def write_metadata_to_file # rubocop:disable Metrics/MethodLength
    metadata = @projects.map do |project|
      {
        full_name: project.full_name,
        status: project.status,
        priority: project.priority,
        type: project.type,
        motivation: project.motivation
      }
    end

    begin
      File.write(@metadata_file, JSON.pretty_generate(metadata))
    rescue SystemCallError, IOError => e
      logger.error "File write failed: #{e.message}"
    end
  end
end
