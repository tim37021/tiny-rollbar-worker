require "benchmark"
require "pry"

boot_time = Benchmark.measure do
  require_relative "boot"
end

puts "Ruby no Rails Console [#{APP_ENV}], boot time: #{boot_time.real}s"
pry
