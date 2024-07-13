#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
# NB: Render Postgres DB Free edition expired. Migrated to Supabase Postgres.
# bundle exec rake db:migrate
# bundle exec rake db:seed