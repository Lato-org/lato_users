require 'fileutils'

namespace :lato_users do
  namespace :install do
    desc 'No-op: Lato Users needs no application-level install step (kept for forward compatibility)'
    # Usage: rails lato_users:install:application
    task :application do
      # Intentionally empty: setup is gem + migrations + mount + imports.
    end
  end
end
