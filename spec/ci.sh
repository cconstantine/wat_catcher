#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Show commands as they are executed


bundle install
bundle exec rspec
