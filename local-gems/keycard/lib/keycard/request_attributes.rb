# frozen_string_literal: true

module Keycard
  # This class is responsible for extracting the user attributes (i.e. the
  # complete set of things that determine the user's #identity), given a Rack
  # request.
  class RequestAttributes
    def initialize(request, finder: InstitutionFinder.new)
      @finder = finder
      @request = request
    end

    def [](attr)
      all[attr]
    end

    def all
      finder.attributes_for(request)
    end

    private

    attr_reader :finder
    attr_reader :request
  end
end
