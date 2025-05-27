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

  def sort_projects(projects, sort_param) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
    projects.sort_by! do |project|
      case sort_param
      when 'name'       then project.name
      when 'status'     then project.status
      when 'priority'   then project.priority
      when 'type'       then project.type
      when 'motivation' then project.motivation
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
