# frozen_string_literal: true

# Load environment
require_relative './config/environment'
require_relative './app'

# Compression
use Rack::Deflater

# Set headers
use Rack::ContentLength

# Logging
use Rack::CommonLogger, MyProjectsDashboard.settings.logger

# Basic auth
use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  username == ENV['DASHBOARD_USER'] && password == ENV['DASHBOARD_PASSWORD']
end

run MyProjectsDashboard
