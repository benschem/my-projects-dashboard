# frozen_string_literal: true

require 'date'

# Project
class Project
  PRIORITIES = %w[high medium low done none].freeze
  MOTIVATION = %w[hot warm cold finished blocked dread].freeze
  STATUSES = %w[live development planning paused archived abandoned].freeze
  TYPE = %w[client teaching job learning personal].freeze

  PRIORITY_ORDER = PRIORITIES.each_with_index.to_h.freeze
  MOTIVATION_ORDER = MOTIVATION.each_with_index.to_h.freeze
  STATUS_ORDER = STATUSES.each_with_index.to_h.freeze
  TYPE_ORDER = TYPE.each_with_index.to_h.freeze

  SORTS = %w[name status priority type motivation created_at pushed_at].freeze

  attr_reader :id, :name, :full_name, :url, :description, :languages, :total_lines, :created_at, :pushed_at
  attr_accessor :status, :priority, :type, :motivation

  def initialize(attributes = {}) # rubocop:disable Metrics/MethodLength
    @name = attributes[:name]
    @full_name = attributes[:full_name]
    @url = attributes[:url]
    @description = attributes[:description]
    @created_at = attributes[:created_at]
    @pushed_at = attributes[:pushed_at]
    @languages = attributes[:languages]
    @total_lines = attributes[:total_lines]
    @status = attributes[:status]
    @priority = attributes[:priority]
    @type = attributes[:type]
    @motivation = attributes[:motivation]
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
