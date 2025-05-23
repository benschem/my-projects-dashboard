# frozen_string_literal: true

# Require Bundler and set up the load paths
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || :development)

# Load environment variables
require 'dotenv'
Dotenv.load
