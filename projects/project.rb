# frozen_string_literal: true

require 'date'

# Project
class Project
  STATUSES = %w[Development Production Archived].freeze
  URGENCY = %w[High Medium Low].freeze
  TYPE = %w[Personal Client Teaching Learning].freeze

  attr_reader :id, :name, :full_name, :url, :description, :languages, :total_lines, :created_at, :pushed_at
  attr_accessor :status, :urgency, :type

  def initialize(attributes = {}) # rubocop:disable Metrics/MethodLength
    @id = attributes[:id]
    @name = attributes[:name]
    @full_name = attributes[:full_name]
    @url = attributes[:url]
    @description = attributes[:description]
    @created_at = attributes[:created_at]
    @pushed_at = attributes[:pushed_at]
    @languages = attributes[:languages]
    @total_lines = attributes[:total_lines]
    @status = attributes[:status]
    @urgency = attributes[:urgency]
    @type = attributes[:type]
  end

  def created_ago
    date_ago(created_at)
  end

  def pushed_ago
    date_ago(pushed_at)
  end

  private

  def date_ago(timestamp)
    return nil unless timestamp

    (Date.today - Date.parse(timestamp.to_s)).to_i
  end
end
