Spectrum
=============

Forked from Columbia Libraries Unified Search &amp; Discovery

## Getting Started for development

1. `mkdir spectrum-project`
1. `git clone git@github.com:mlibrary/spectrum.git spectrum-project/spectrum`
1. `git clone git@github.com:mlibrary/spectrum-config.git spectrum-project/spectrum-config`
1. `git clone git@github.com:mlibrary/spectrum-json.git spectrum-project/spectrum-json`
1. `cd spectrum-project/spectrum BUNDLE_GEMFILE=Gemfile.dev bundle install --path .bundle`
1. Get a copy of the config files from the dev server.
1. `tar xf spectrum-dev-config.tar`
1. `BUNDLE_GEMFILE=Gemfile.dev bundle exec rackup`

## Overview of Spectrum

Spectrum is the server-side support for [Search](https://github.com/mlibrary/search).  It is intended to mediate requests to solr and summon as a back-end interface to support library Search.

## Dependencies

* [spectrum-config](https://github.com/mlibrary/spectrum-config)

    * Spectrum-config handles individualized configuration of the targets searchable in the front-end.  It works a lot like a jello-mold.  Pour the user's request into it, get a tasty treat out.

* [spectrum-json](https://github.com/mlibrary/spectrum-json)

    * Spectrum-json handles receiving requests from end-users, applying any global normalization to the request, and passing it to the appropriate configuration to make a search against solr or summon.
    * Spectrum-json also handles things like taking actions on records, and identifying patron affiliation.
