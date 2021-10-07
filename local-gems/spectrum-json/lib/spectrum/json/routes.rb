# frozen_string_literal: true

Spectrum::Json::Engine.routes.draw do
  match '',
        to: 'json#index',
        via: %i[get post options]

  Spectrum::Json.routes(self)
end
