require "lato_users/version"
require "lato_users/engine"
require "lato_users/config"

module LatoUsers
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
