# frozen_string_literal: true

require_relative '../projects/project'

module FilterHelpers # rubocop:disable Style/Documentation
  def allowed_sorts
    Project::SORTS
  end

  def build_filters(params)
    status_filters = Array(params[:status]) & project_statuses
    priority_filters = Array(params[:priority]) & project_priorities
    type_filters = Array(params[:type]) & project_types
    motivation_filters = Array(params[:motivation]) & project_motivations

    {
      status: status_filters,
      priority: priority_filters,
      type: type_filters,
      motivation: motivation_filters
    }
  end

  def project_matches_filter?(filter_by, filters, project)
    project_value = case filter_by
                    when :status     then project.status
                    when :priority   then project.priority
                    when :type       then project.type
                    when :motivation then project.motivation
                    end

    filters.include?(project_value&.to_s)
  end
end
