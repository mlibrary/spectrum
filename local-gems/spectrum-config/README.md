# Spectrum::Config

[![Coverage Status](https://coveralls.io/repos/github/mlibrary/spectrum-config/badge.svg?branch=master)](https://coveralls.io/github/mlibrary/spectrum-config?branch=master)

Spectrum::Config is a collection of utilities that support the configuration of the spectrum / spectrum-json application.

The notable concepts involved are:

1. `Spectrum::Config::Source` is a source of data.
    Currently, sources may be solr indexes, or a summon index.

2. `Spectrum::Config::Focus` is a potentially pre-filtered view of a source.
    One source may supply multiple foci.

3. `Spectrum::Config::Field` describe the data that comes from a source.  Some fields are searchable, some are facetable, some are just for presenting data.
    Many fields are extract from MARC-XML formatted data, and the logic to do that is the subject of many classes in Spectrum::Config.

4. `Spectrum::Config::Filter` describes operations that may be taken on fields to transform the data provided by the field.  

5. Adjacent to the topic of extracting and transforming data, formatting it specifically for rendering as a `Spectrum::Config::MetadataComponent`, `Spectrum::Config::CSL` citation, and `Spectrum::Config::Z3988` COinS has received a fair amount of attention.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spectrum-config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spectrum-config

## Usage


## Copyright

Copyright (c) 2015, Regents of the University of Michigan.

All rights reserved. See [LICENSE.txt](LICENSE.txt) for details.

