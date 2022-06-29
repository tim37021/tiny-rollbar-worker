require "sidekiq"
require "connection_pool"

use_ssl = ENV["REDIS_ENABLE_SSL"] == "true" || ENV["REDIS_ENABLE_SSL"] == "1"

REDIS_CONN = proc do
  Redis.new(
    host: ENV["REDIS_HOST"],
    port: ENV["REDIS_PORT"]&.to_i,
    db: ENV["REDIS_DB"]&.to_i,
    ssl: use_ssl,
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