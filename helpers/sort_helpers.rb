# frozen_string_literal: true

module SortHelpers # rubocop:disable Style/Documentation
  def sorted_projects(projects, params)
    sort_by = validate_sort_param(params[:sort])
    return projects unless sort_by

    sorted_projects = sort_projects(projects, sort_by)

    direction = validate_direction_param(params[:direction])
    direction == 'desc' ? sorted_projects.reverse! : sorted_projects
  end

  private

  def validate_sort_param(param)
    allowed_sorts.include?(param) ? param : nil
  end

  def validate_direction_param(param)
    param == 'desc' ? 'desc' : 'asc'
  end

  def sort_projects(projects, sort_param) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/AbcSize
    projects.sort_by! do |project|
      case sort_param
      when 'name'       then project.name
      when 'status'     then Project::STATUS_ORDER[project.status] || 999
      when 'priority'   then Project::PRIORITY_ORDER[project.priority] || 999
      when 'type'       then Project::TYPE_ORDER[project.type] || 999
      when 'motivation' then Project::MOTIVATION_ORDER[project.motivation] || 999
      when 'created_at' then time(project.created_at)
      when 'pushed_at'  then time(project.pushed_at)
      end
    end
  end

  def time(timestamp)
    Time.parse(timestamp.to_s)
  rescue ArgumentError, TypeError
    logger.warn "Failed to parse Timestamp: #{e.class} - #{e.message} "
    nil
  end
end
