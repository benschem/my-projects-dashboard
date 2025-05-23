# frozen_string_literal: true

# Project
class Project
  STATUSES = %w[Development Production Archived].freeze
  URGENCY = %w[High Medium Low].freeze
  TYPE = %w[Personal Client Teaching Learning].freeze

  attr_reader :id, :name, :full_name, :url, :description, :languages, :total_lines
  attr_accessor :status, :urgency, :type

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @full_name = attributes[:full_name]
    @url = attributes[:url]
    @description = attributes[:description]
    @languages = attributes[:languages]
    @total_lines = attributes[:total_lines]
    @status = attributes[:status]
    @urgency = attributes[:urgency]
    @type = attributes[:type]
  end
end
