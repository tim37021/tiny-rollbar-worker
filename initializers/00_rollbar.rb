require "rollbar"
require "rollbar/delay/sidekiq"

Rollbar.configure do |config|
  # Without configuration, Rollbar is enabled in all environments.
  # To disable in specific environments, set config.enabled=false.

  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]

  config.enabled = true
  config.environment = APP_ENV

  # https://docs.rollbar.com/docs/ruby
  config.scrub_headers |= %w[X-XFERS-APP-API-KEY X-XFERS-USER-API-KEY]

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`,
  # `username`, and `email` methods to fetch those properties. To customize:
  # config.person_method = "my_current_user"
  # config.person_id_method = "my_id"
  # config.person_username_method = "my_username"
  # config.person_email_method = "my_email"

  # If you want to attach custom data to all exception and message reports,
  # provide a lambda like the following. It should return a hash.
  config.custom_data_method = -> { { env: APP_ENV } }

    # Enable asynchronous reporting (uses girl_friday or Threading if girl_friday
  # is not installed)
  # config.use_async = true

  # Supply your own async handler:
  # config.async_handler = Proc.new { |payload|
  #  Thread.new { Rollbar.process_from_async_handler(payload) }
  # }

  # Enable asynchronous reporting (using sucker_punch)
  # config.use_sucker_punch

  # Enable delayed reporting (using Sidekiq)
  config.use_sidekiq queue: "rollbar"
  config.sidekiq_threshold = 3

  # https://github.com/rollbar/rollbar-gem#failover-handlers
  config.failover_handlers = [Rollbar::Delay::Thread]

  config.logger = Logger.new(STDOUT)
end

