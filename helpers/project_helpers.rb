# frozen_string_literal: true

require_relative '../projects/project_repository'
require_relative '../projects/project'

module ProjectHelpers # rubocop:disable Style/Documentation
  def projects
    settings.projects
  end

  def github
    settings.github_repo_exporter
  end

  def reload_projects!
    settings.projects = ProjectRepository.new(logger: logger)
  end

  def project_statuses
    Project::STATUSES
  end

  def project_priorities
    Project::PRIORITIES
  end

  def project_types
    Project::TYPE
  end

  def project_motivations
    Project::MOTIVATION
  end
end
