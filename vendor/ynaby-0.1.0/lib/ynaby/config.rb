require "mixlib/config"

module Ynaby
  extend Mixlib::Config
  config_strict_mode true
  configurable :api_token
end
