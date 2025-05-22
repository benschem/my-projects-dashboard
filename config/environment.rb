# frozen_string_literal: true

# Require Bundler and set up the load paths
require 'bundler/setup'
Bundler.require(:default, ENV['APP_ENV'] || :development)

# Load environment variables
require 'dotenv'
Dotenv.load
