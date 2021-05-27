Spectrum
=============

Forked from Columbia Libraries Unified Search &amp; Discovery

## Using docker-compose for development

```bash
git clone git@github.com:mlibrary/spectrum.git spectrum
git clone git@github.com:mlibrary/spectrum-config.git spectrum/gems/spectrum-config
git clone git@github.com:mlibrary/spectrum-json.git spectrum/gems/spectrum-json
cd spectrum
docker-compose build
docker-compose run web bundle install
docker-compose run web bundle exec rake 'search[v1.14.21,local]'
docker-compose start web
docker-compose attach web
```

## Getting Started for development

1. `mkdir spectrum-project`
1. `git clone git@github.com:mlibrary/spectrum.git spectrum-project/spectrum`
1. `git clone git@github.com:mlibrary/spectrum-config.git spectrum-project/spectrum-config`
1. `git clone git@github.com:mlibrary/spectrum-json.git spectrum-project/spectrum-json`
1. `cd spectrum-project/spectrum`
1. `BUNDLE_GEMFILE=Gemfile.dev bundle install --path .bundle`
1. Get a copy of the config files from the dev server.
1. `tar xf spectrum-dev-config.tar`
1. Update the values in `.env` from `spectrum-dev-config.tar`.
    You'll probably use:
    ```bash
    RAILS_RELATIVE_URL_ROOT=http://localhost:9292/spectrum
    SPECTRUM_INST_LOCATION_FILES_DIR=config
    SPECTRUM_SEARCH_GIT_BRANCH=master
    SPECTRUM_PRIDE_GIT_BRANCH=master
    REACT_APP_LOGIN_BASE_URL=http://localhost:9292
    REACT_APP_SPECTRUM_BASE_URL=http://localhost:9292/spectrum
    ```
1. `BUNDLE_GEMFILE=Gemfile.dev bundle exec rake assets:precompile`
1. `BUNDLE_GEMFILE=Gemfile.dev bundle exec rackup`

## Overview of Spectrum

Spectrum is the server-side support for [Search](https://github.com/mlibrary/search).  It is intended to mediate requests to solr and summon as a back-end interface to support library Search.

## Dependencies

* [spectrum-config](https://github.com/mlibrary/spectrum-config)

    * Spectrum-config handles individualized configuration of the targets searchable in the front-end.  It works a lot like a jello-mold.  Pour the user's request into it, get a tasty treat out.

* [spectrum-json](https://github.com/mlibrary/spectrum-json)

    * Spectrum-json handles receiving requests from end-users, applying any global normalization to the request, and passing it to the appropriate configuration to make a search against solr or summon.
    * Spectrum-json also handles things like taking actions on records, and identifying patron affiliation.
