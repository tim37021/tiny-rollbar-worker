# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rspec", "~> 3.11"
gem "sidekiq", "~> 6.4"
gem "rollbar", "~> 3.3"
gem "dotenv", "~> 2.7"
gem "redis", "~> 4.6"
gem "rake", "~> 13.0"
gem "connection_pool", "~> 2.2"
gem "sidekiq-alive", git: "https://github.com/Xfers/sidekiq-alive.git", tag: "v3.1.0"

group :development do
  gem "pry"
end

# This will be used in console mode
group :console do
end
