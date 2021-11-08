# frozen_string_literal: true
require 'byebug'

class JsonController < ApplicationController
  before_filter :init, :cors

  AA_ADDRESSES = [
    IPAddr.new('35.0.0.0/16'),
    IPAddr.new('35.1.0.0/16'),
    IPAddr.new('35.2.0.0/16'),
    IPAddr.new('35.3.0.0/16'),
    IPAddr.new('67.194.0.0/16'),
    IPAddr.new('141.211.0.0/16'),
    IPAddr.new('141.212.0.0/16'),
    IPAddr.new('141.213.0.0/16'),
    IPAddr.new('141.214.0.0/16'),
    IPAddr.new('192.12.80.0/24'),
    IPAddr.new('198.108.8.0/21'),
    IPAddr.new('198.111.224.0/22'),
    IPAddr.new('198.111.181.0/25'),
    IPAddr.new('207.75.144.0/20'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16')
  ]

  FLINT_ADDRESSES = [
    IPAddr.new('141.216.0.0/16')
  ]

  def cors
    headers['Access-Control-Allow-Origin'] = get_origin(request.headers)
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Referer'
    headers['Access-Control-Allow-Credentials'] = 'true'
    render text: '', content_type: 'text/plain' if request.method == 'OPTIONS'
  end

  def init
    @engine      = nil
    @response    = nil
    @messages    = []
    @focus       = Spectrum::Json.foci[params[:focus]]
    @source      = Spectrum::Json.sources[params[:source]]
    no_cache unless production?
  end

  def act
    render(json: response_class.new(request_class.new(request)).spectrum)
  end

  def file
    send_data(
      response_class.new(request_class.new(request)).data,
      type: 'application/x-research-info-systems',
      disposition: 'attachment',
      filename: 'Library Search Record Export.ris'
    )
  end

  def profile
    no_cache
    render(json: response_class.new(request_class.new(request)).spectrum)
  end

  def index
    @request     = Spectrum::Request::Null.new
    @new_request = Spectrum::Request::Null.new
    @response    = Spectrum::Response::DataStoreList.new(list_datastores)
    render(json: basic_response)
  end

  def browse
    @request = Spectrum::Request::BrowseRequest.new(request, @focus, :desc)
    @datastore = Spectrum::Response::DataStore.new(this_datastore)
    @response = Spectrum::Response::RecordList.new(fetch_browse_records, @request)
    prev_page = @response.spectrum
    @request      = Spectrum::Request::BrowseRequest.new(request, @focus, :asc)
    @engine = @source.engine(@focus, @request, self)
    @datastore    = Spectrum::Response::DataStore.new(this_datastore)
    @response     = Spectrum::Response::RecordList.new(fetch_browse_records, @request)
    this_page = @response.spectrum

    #if prev_page and this_page
      #first_before_id = prev_page[0][:fields].find{|e| e[:uid] == "title"}[:value]
      #first_after_id =  this_page[0][:fields].find{|e| e[:uid] == "title"}[:value]
      #full_records = if first_before_id == first_after_id
                        #prev_page[1..2].reverse.concat(this_page)
                     #else
                       #prev_page[0..1].reverse.concat(this_page)
                     #end
    #else
      #full_records = this_page
    #end

    #full_response = browse_response(prev_page, full_records)
    fields = [
      {
        label: "Keyword",
        value: "keyword"
      },
      {
        label: "Author",
        value: "author"
      },
      {
        label: "Title",
        value: "title"
      },
      {
        label: "Browse by (LC) call number",
        value: "browse-by-callnumber"
      }
    ]

    stub_response = [
      {
        callnumber: 'Z 253 .U582 1984',
        title: 'Patents and trademarks style menu :',
        subtitles: [
          'United States. Patent and Trademark Office.',
          'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
        ]
      },
      {
        callnumber: 'Z 253 .U582 1984',
        title: 'Patents and trademarks style menu :',
        subtitles: [
          'United States. Patent and Trademark Office.',
          'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
        ]
      },
      {
        callnumber: 'Z 253 .U582 1984',
        title: 'Patents and trademarks style menu :',
        subtitles: [
          'United States. Patent and Trademark Office.',
          'Office : For sale by the Supt. of Docs., U.S. G.P.O., 1984.'
        ]
      }
    ]
    render(locals: {
      fields: fields,
      results: stub_response,
      #full_response: full_response,
      full_response: [],
    })
  end

  def search
    @request      = Spectrum::Request::DataStore.new(request, @focus)
    @new_request  = Spectrum::Request::DataStore.new(request, @focus)
    @datastore    = Spectrum::Response::DataStore.new(this_datastore)
    @specialists  = Spectrum::Response::Specialists.new(specialists)
    @response     = Spectrum::Response::RecordList.new(fetch_records, @request)
    full_response = search_response

    if @source.holdings
      full_response[:response].each do |record|
        holdings_request = Spectrum::Request::Holdings.new({id: record[:uid]})
        holdings_response = Spectrum::Response::Holdings.new( @source, holdings_request )
        record.merge!(holdings: holdings_response.renderable)
      end
    else
      full_response[:response].each do |record|
        record.merge!(holdings: Spectrum::Response::NullHoldings.new.renderable)
      end
    end

    render(json: full_response)
  end

  def facet
    @request      = Spectrum::Request::Facet.new(request)
    @new_request  = Spectrum::Request::Facet.new(request)
    @datastore    = Spectrum::Response::DataStore.new(this_datastore)
    @response     = Spectrum::Response::FacetList.new(fetch_facets)
    render(json: facet_response)
  end

  def record
    @request   = Spectrum::Request::Record.new(request)
    @datastore = Spectrum::Response::DataStore.new(this_datastore)
    if engine.total_items > 0
      @response = Spectrum::Response::Record.new(fetch_record, @request)
      holdings_response = if @source.holdings
        holdings_request = Spectrum::Request::Holdings.new(request)
        Spectrum::Response::Holdings.new(@source, holdings_request)
      else
        Spectrum::Response::NullHoldings.new
      end
      render(json: record_response.merge(holdings: holdings_response.renderable))
    else
      render(json: {}, status: 200)
    end
  end

  def hold_redirect
    @request = Spectrum::Request::PlaceHold.new(request)
    Spectrum::Response::PlaceHold.new(@request).renderable
    redirect_to 'https://www.lib.umich.edu/my-account/holds-recalls', status: 302
  end

  def hold
    @request = Spectrum::Request::PlaceHold.new(request)
    @response = Spectrum::Response::PlaceHold.new(@request)
    render(json: @response.renderable)
  end

  def holdings
    @request = Spectrum::Request::Holdings.new(request)
    @response = Spectrum::Response::Holdings.new(@source, @request)
    render(json: @response.renderable)
  end

  def get_this
    @request = Spectrum::Request::GetThis.new(request)
    @response = Spectrum::Response::GetThis.new(source: @source, request: @request)
    render(json: @response.renderable)
  end

  def holdings_response
    @response.spectrum
  end

  def record_response
    @response.spectrum
  end

  def show
    render json: 'json#show'
  end

  def ids
    @request = Spectrum::Request::Ids.new(request)
    @response = Spectrum::Response::Ids.new(@request)
    redirect_to(@response.uri, status: @response.status)
  end

  def debug
    @request = Spectrum::Request::Debug.new(request)
    @response = Spectrum::Response::Debug.new(@request)
    render json: @response.renderable
  end

  def current_user
    nil
  end

  def bad_request
    render nothing: true, status: 400
  end

  def service_unavailable
    render nothing: true, status: 503
  end

  private

  def get_origin(headers)
    return headers['origin'] if headers['origin']
    return '*' unless headers['referer']
    uri = URI(request.headers['referer'])
    "#{uri.scheme}://#{uri.host}#{[80, 443].include?(uri.port) ? '' : ':' + uri.port.to_s}"
  end

  def no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Mon, 01 Jan 1990 00:00:00 GMT'
  end

  def engine
    @engine = @source.engine(@focus, @request, self) if @engine.nil?
    @engine
  end

  def list_datastores
    base_url.merge(
      data: Spectrum::Json.foci
    )
  end

  def this_datastore
    base_url.merge(
      data: @focus.apply(@request, engine.search)
    )
  end

  def fetch_record
    base_url.merge(
      data: engine.results.first,
      source: @source,
      focus: @focus
    )
  end

  def specialists
    base_url.merge(
      request: @request,
      source: @source,
      focus: @focus
    )
  end

  def fetch_holdings
    base_url.merge(
      data: @request.fetch_holdings,
      source: @source,
      focus: @focus
    )
  end

   def fetch_browse_records
    base_url.merge(
        data: engine.results,
        source: @source,
        focus: @focus
    )
  end

  def fetch_records
    base_url.merge(
      data: engine.results,
      source: @source,
      focus: @focus,
      total_available: engine.total_items,
      specialists: @specialists.spectrum
    )
  end

  def fetch_facets
    base_url.merge(
      datastore: @datastore,
      source: @source,
      focus: @focus,
      facet: params[:facet],
      total_available: nil
    )
  end

  def base_url
    { base_url: config.relative_url_root }
  end

  def get_ip_addr
    if request.env['REMOTE_ADDR'] != '127.0.0.1'
      request.env['REMOTE_ADDR']
    elsif request.env['HTTP_X_FORWARDED_FOR']
      request.env['HTTP_X_FORWARDED_FOR'].split(/ /).last
    else
      '127.0.0.1'
    end
  end

  def default_affiliation
    case IPAddr.new(get_ip_addr)
    when *AA_ADDRESSES
      'aa'
    when *FLINT_ADDRESSES
      'flint'
    else
      'aa'
    end
  end

  # TODO: Move this into configuration.
  def default_institution
    case IPAddr.new(get_ip_addr)
    when *AA_ADDRESSES
      'U-M Ann Arbor Libraries'
    when *FLINT_ADDRESSES
      'Flint Thompson Library'
    else
      'All libraries'
    end
  end

  def basic_response
    {
      request:  @request.spectrum,
      response: @response.spectrum(filter_limit: -1),
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available,
      default_institution: default_institution,
      affiliation: default_affiliation,
    }
  end

  def browse_response(prev_page, full_records)
    {
        request:  @request.spectrum,
        response: full_records,
        datastore: @datastore.spectrum,
        prev_page_start: prev_page.last[:fields].find {|f| f[:uid] == 'callnumber'}[:value].first,
        next_page_start: full_records.last[:fields].find {|f| f[:uid] == 'callnumber'}[:value].first
    }
  end

  def search_response
    {
      request:  @request.spectrum,
      response: @response.spectrum,
      messages: (@messages + @request.messages).map(&:spectrum),
      total_available: @response.total_available,
      specialists: @specialists.spectrum,
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    }
  end

  def facet_response
    {
      request:  @request.spectrum,
      response: @response.spectrum,
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available,
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    }
  end

  def request_class
    "Spectrum::Request::#{request.params[:type]}".constantize
  end

  def response_class
    "Spectrum::Response::#{request.params[:type]}".constantize
  end

  def production?
    request.env['SERVER_NAME'] == 'search.lib.umich.edu'
  rescue StandardError
    false
  end
end
