# frozen_string_literal: true

require_relative 'project'

# Project
class ProjectRepository
  def initialize(repo_file)
    @repo_file = repo_file
    @metadata_file = 'data/metadata.json'
    @projects = []
    @next_id = 1
    load_projects if File.exist?(@repo_file)
  end

  def all
    @projects
  end

  def find(id)
    @projects.find { |element| element.id == id }
  end

  def update(project)
    project = find(project.id)
    project.status = project[:status]
    project.urgency = project[:urgency]
    project.type = project[:type]
    save_metadata
  end

  private

  def load_projects
    # TODO: Some kind of cache system so this can be updated without restarting
    repos = JSON.parse(File.read(@repo_file), symbolize_names: true)
    metadata = JSON.parse(File.read(@metadata_file), symbolize_names: true) if File.exist?(@metadata_file)
    repos.each_with_index do |repo, index|
      repo[:id] = metadata ? metadata[index][:id] : @next_id
      repo[:status] = metadata ? metadata[index][:status] : nil
      repo[:urgency] = metadata ? metadata[index][:urgency] : nil
      repo[:type] = metadata ? metadata[index][:type] : nil
      @projects << Project.new(repo)
      @next_id += 1
    end
    save_metadata unless File.exist?(@metadata_file)
  end

  def save_metadata
    metadata = @projects.map do |project|
      { id: project.id, status: project.status, urgency: project.urgency, type: project.type }
    end
    File.write(@metadata_file, JSON.pretty_generate(metadata))
  end
end
