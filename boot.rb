require "dotenv"

Dotenv.load
APP_ENV = ENV["APP_ENV"]&.to_sym || :development

Bundler.setup(:default, APP_ENV)

Dir.glob("initializers/**/*.rb").sort.map{|s| s[0..-4]}.each do |v|
  require_relative v
end

