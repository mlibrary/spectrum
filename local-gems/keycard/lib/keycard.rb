# frozen_string_literal: true

require "keycard/version"
require "sequel"

# All of the Keycard components are contained within this top-level module.
module Keycard
end

require "keycard/db"
require "keycard/railtie" if defined?(Rails)
require "keycard/request_attributes"
require "keycard/institution_finder"
