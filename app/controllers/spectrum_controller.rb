#
# SpectrumController#search() - primary entry point for searches against
# Summon or GoogleAppliance, or for any Aggregate searches
#   - figures out the sources, then for each one calls:
#     SpectrumController#get_results()
#     - which for each source
#       - fixes input parameters in a source-specific way,
#       - calls either:  Spectrum::SearchEngines::Summon.new(fixed_params)
#       -           or:  blacklight_search(fixed_params)
#
# SpectrumController#fetch() - alternative entry point
#   - does the same thing, but for AJAX calls, returning JSON
#
class SpectrumController < ApplicationController
  layout 'quicksearch'

  attr_reader :active_source
  def search
    @results = []

    # process any Filter Queries - turn Summon API Array of key:value pairs into
    # nested Rails hash (see inverse transform in Spectrum::SearchEngines::Summon)
    #  BEFORE: params[s.fq]="AuthorCombined:eric foner"
    #  AFTER:  params[s.fq]={"AuthorCombined"=>"eric foner"}
    # [This logic is here instead of fix_summon_params, because it needs to act
    #  upon the true params object, not the cloned copy.]
    if params['s.fq'].kind_of?(Array) || params['s.fq'].kind_of?(String)
      new_fq = {}
      key_value_array = []
      Array.wrap(params['s.fq']).each do |key_value|
        key_value_array  = key_value.split(':')
        new_fq[ key_value_array[0]] = key_value_array[1] if key_value_array.size == 2
      end
      params['s.fq'] = new_fq
    end

    session['search'] = params

    @search_layout = FOCUS_CONFIG[params['layout']].layout

    # First, try to detect if we should go to the landing page.
    # But... Facet-Only searches are still searches.
    # (Compare logic from SearchHelper#has_search_parameters?)
    if params['q'].nil? && params['s.q'].nil? &&
       params['s.fq'].nil? && params['s.ff'].nil? ||
      (params['q'].to_s.empty? && @active_source == 'library_web')
      flash[:error] = 'You cannot search with an empty string.' if params['commit']
    elsif @search_layout.nil?
      flash[:error] = 'No search layout specified'
      redirect_to root_path
    else
      @search_style = @search_layout.style
      # @has_facets = @search_layout['has_facets']
      sources = @search_layout.sources

      @action_has_async = true if @search_style == 'aggregate'

      if @search_style == 'aggregate' && !session[:async_off]
        @action_has_async = true
        @results = {}
        sources.each { |source| @results[source] = {} }
      else
        @results = get_results(sources)
      end

    end

    @show_landing_pages = true if @results.empty?
  end

  def fetch
    #@search_layout = SEARCHES_CONFIG['layouts'][params[:layout]]
    @search_layout = FOCUS_CONFIG[params['layout']].layout

    @active_source = @datasource = params[:datasource]

    if @search_layout.nil?
      render text: 'Search layout invalid.'
    else
      @fetch_action = true
      @search_style = @search_layout.style
      # @has_facets = @search_layout.has_facets
      sources = @search_layout.sources.select { |source| source == @datasource }
      @results = get_results(sources)
      render 'fetch', layout: 'js_return'
   end
  end

  def on_campus?
    @user_characteristics[:on_campus]
  end

  def logged_in?
    !current_user.nil?
  end

  private

  def fix_ga_params(params)
    # items-per-page ("rows" param) should be a persisent browser setting
    if params['rows'] && (params['rows'].to_i > 1)
      # Store it, if passed
      set_browser_option('ga_per_page', params['rows'])
    else
      # Retrieve and use previous value, if not passed
      ga_per_page = get_browser_option('ga_per_page')
      if ga_per_page && (ga_per_page.to_i > 1)
        params['rows'] = ga_per_page
      end
    end

    params
  end

  def get_results(sources)
    @result_hash = {}
    new_params = params.to_hash
    sources.listify.each do |source|

      fixed_params = SOURCE_CONFIG[source].fix_params(new_params, self)

      # "results" is not the search results, it's the Search Engine object, in a
      # post-search-execution state.
      results = case SOURCE_CONFIG[source].type
      when 'summon'
          Spectrum::SearchEngines::Summon.new(fixed_params)
      when 'solr'
          blacklight_search(fixed_params)
      else
        fail "SpectrumController#get_results() unhandled source: '#{source}' #{SOURCE_CONFIG[source].type}"
      end

      @result_hash[source] = results
    end

    @result_hash
  end
end
