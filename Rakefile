# frozen_string_literal: true

namespace :data do
  desc 'Manually manage project data'

  # rake middleware:list
  task :refresh do
    require 'dotenv/load'
    require_relative './scripts/refresh_data'

    puts 'Refreshing repo data from Github...'

    call

    puts 'Done.'
  end
end
