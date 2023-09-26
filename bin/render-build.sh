#!/usr/bin/env bash
# exit on error
set -o errexit

# rails build
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# run database migrations
bundle exec rake db:migrate
