require "sidekiq"
require "connection_pool"

REDIS_CONN = proc do
  Redis.new(
    host: ENV["REDIS_HOST"],
    port: ENV["REDIS_PORT"],
    db: ENV["REDIS_DB"],
    timeout: 180,
  )
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 10, &REDIS_CONN)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 10, &REDIS_CONN)
end

require "sidekiq-alive"