module Spectrum
  module Json
    class App < Sinatra::Base
      module Search
        def self.included(app)
          Spectrum::Json.routes(app)
        end

        def this_datastore(focus:, spectrum_request:, engine:)
          base_url.merge(
            data: focus.apply(spectrum_request, engine.search)
          )
        end

        def specialist_base(spectrum_request:, source:, focus:)
          base_url.merge(
            request: spectrum_request,
            source: source,
            focus: focus
          )
        end

        def fetch_records(engine:, source:, focus:, specialists:)
          base_url.merge(
            data: engine.results,
            source: source,
            focus: focus,
            total_available: engine.total_items,
            specialists: specialists
          )
        end

        def fetch_record(engine:, source:, focus:)
          base_url.merge(
            data: engine.results.first,
            source: source,
            focus: focus
          )
        end

        def search_response(spectrum_request:, spectrum_response:, messages:, specialists:, datastore:, new_spectrum_request:)
          {
            request: spectrum_request.spectrum,
            response: spectrum_response.spectrum,
            messages: (messages + spectrum_request.messages).map(&:spectrum),
            total_available: spectrum_response.total_available,
            specialists: specialists.spectrum,
            datastore: datastore.spectrum,
            new_request: new_spectrum_request.spectrum
          }
        end

        def search(focus:, source:)
          cors
          spectrum_request = Spectrum::Request::DataStore.new(request, focus)
          new_spectrum_request = Spectrum::Request::DataStore.new(request, focus)
          engine = source.engine(focus, spectrum_request, self)
          datastore = Spectrum::Response::DataStore.new(
            this_datastore(focus: focus, spectrum_request: spectrum_request, engine: engine)
          )
          specialists = Spectrum::Response::Specialists.new(
            specialist_base(spectrum_request: spectrum_request, source: source, focus: focus)
          )
          spectrum_response = Spectrum::Response::RecordList.new(
            fetch_records(engine: engine, source: source, focus: focus, specialists: specialists),
            spectrum_request
          )
          messages = []

          full_response = search_response(
            spectrum_request: spectrum_request,
            spectrum_response: spectrum_response,
            messages: messages,
            specialists: specialists,
            datastore: datastore,
            new_spectrum_request: new_spectrum_request
          )

          if source.holdings
            ActiveSupport::Notifications.instrument("search_results_holdings_retrieval.spectrum_json_search", full_response: full_response) do
              full_response[:response].each do |record|
                holdings_request = Spectrum::Request::Holdings.new({id: record[:uid]})
                holdings_response = Spectrum::Response::Holdings.new(source, holdings_request)
                record.merge!(holdings: holdings_response.renderable)
              end
            end
          else
            full_response[:response].each do |record|
              record.merge!(holdings: Spectrum::Response::NullHoldings.new.renderable)
            end
          end

          json(full_response)
        end

        def record(source:, focus:)
          cors
          spectrum_request = Spectrum::Request::Record.new(request)
          engine = source.engine(focus, spectrum_request, self)
          if engine.total_items > 0
            spectrum_response = Spectrum::Response::Record.new(
              fetch_record(source: source, focus: focus, engine: engine),
              spectrum_request
            )
            holdings_response = if source.holdings
              ActiveSupport::Notifications.instrument("single_record_holdings_retrieval.spectrum_json_search", spectrum_response: spectrum_response) do
                holdings_request = Spectrum::Request::Holdings.new(request)
                Spectrum::Response::Holdings.new(source, holdings_request)
              end
            else
              Spectrum::Response::NullHoldings.new
            end
            json(spectrum_response.spectrum.merge(holdings: holdings_response.renderable))
          else
            json({})
          end
        end
      end
    end
  end
end
