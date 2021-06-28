Spectrum
=============

Forked from Columbia Libraries Unified Search &amp; Discovery

## Using docker-compose for development

```bash
git clone git@github.com:mlibrary/spectrum.git spectrum
git clone git@github.com:mlibrary/spectrum-config.git spectrum/gems/spectrum-config
git clone git@github.com:mlibrary/spectrum-json.git spectrum/gems/spectrum-json
cd spectrum
cp /path/to/env-file .env
docker-compose up --build --no-start
docker-compose run --rm -u 0 web bash -c 'chown -R "${UID}:${GID}" "${BUNDLE_PATH}"'
docker-compose run --rm web bundle install
docker-compose run --rm web bundle exec rake 'search[v1.14.21,local]'
docker-compose start web && docker attach "$(docker-compose ps -q web)"
```

## Overview of Spectrum

Spectrum is the server-side support for [Search](https://github.com/mlibrary/search).  It is intended to mediate requests to solr and summon as a back-end interface to support library Search.

## Dependencies

* [spectrum-config](https://github.com/mlibrary/spectrum-config)

    * Spectrum-config handles individualized configuration of the targets searchable in the front-end.  It works a lot like a jello-mold.  Pour the user's request into it, get a tasty treat out.

* [spectrum-json](https://github.com/mlibrary/spectrum-json)

    * Spectrum-json handles receiving requests from end-users, applying any global normalization to the request, and passing it to the appropriate configuration to make a search against solr or summon.
    * Spectrum-json also handles things like taking actions on records, and identifying patron affiliation.
