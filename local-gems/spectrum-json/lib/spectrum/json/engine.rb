# frozen_string_literal: true

module Spectrum
  module Json
    class Engine < Rails::Engine
      # paths['app/controllers'] = 'lib/spectrum/json/controllers'
      paths['config/routes.rb'] = 'lib/spectrum/json/routes.rb'
    end
  end
end
