# Areas for improvement

* Organization of `Spectrum::Config::`
    * source.rb needs to be split up because it contains multiple classes.
    * Lots of other classes should be split up for conceptual and organization reasons.

* Solr and Summon query generation
    * Remove dependency on CLIO and Blacklight (`spectrum:app/models/spectrum/search_engines/solr.rb`, `spectrum:app/models/spectrum/search_engines/summon.rb`). 
    * Put more query generation logic in the same place. 
    * Generate queries that work as planned for solr (i.e. expand aliases so they have a real pf or bq)
        * `field:value` => `_query_:"{!dismax qf=$field.qf pf=$field.pf bq=$field.bq v=$field.clauseN}"`
        * query generation will need to add arbitrary variables to the query (i.e. `$field.clauseN`)
    * Some of this is in `spectrum-json:lib/spectrum/field_tree/` files
    * facet generation is handled some in `spectrum-config:lib/spectrum/config/source.rb`

* Anything that needs to access record metadata for making decisions.
    * Could use a decorator or something informed by the configuration.
    * Export code (RIS, and CSL, COinS) was shoehorned in late and in a hurry
        * `spectrum-config:lib/spectrum/config/focus.rb`
    * Holdings processing
    * Get This url generation

* Pride's query parser was never really developed.
    * Code is at: https://github.com/mlibrary/pride/blob/master/source/parser/parser.pegjs
    * It uses https://pegjs.org/
    * What we have is a stub that was being used as a placeholder when things were launched.
    * We don't have agreement on what the parse should be for various edge cases.

* Filters / data rewriting altering
    * Filters like the proxy prefix needs to know about the user's affiliation.
    * Currently accomplished by passing the request object all the way down to the filter to make that decision.
    * Maybe move towards building each request's filter stack with that information in mind, rather than assembling one stack to apply every time.
