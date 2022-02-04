# configuration of the gem and
# default values set here
module RailsAsyncMigrations
  class Config
    attr_accessor :taken_methods, :mode, :workers, :sidekiq_queue, :delay, :retry

    def initialize
      @taken_methods = %i[change up down]
      @mode = :quiet # :verbose, :quiet
      @workers = :delayed_job # :sidekiq
      @sidekiq_queue = :default
      @delay = 0
      @retry = true
    end
  end
end
