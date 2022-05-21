#!/bin/bash
# WORKING_DIR ..
bundle exec sidekiq -r ./boot.rb -q rollbar -c 2

