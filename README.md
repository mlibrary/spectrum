Spectrum
=============

Forked from Columbia Libraries Unified Search &amp; Discovery

## Using docker-compose for development

Clone the repository
```bash
git clone git@github.com:mlibrary/spectrum.git spectrum
cd spectrum
```
Copy .env-example to .env
```
cp .env-example .env
```
Get the actual values for the `.env` file from one of the developers. Update `.env` with those values.

Build it.
```
docker-compose up --build --no-start
```

Install the gems into the gem-cache
```
docker-compose run --rm web bundle install
```

Pull the latest version of the search front end
```
docker-compose run --rm web bundle exec rake 'search[latest,local]'
```

Load up the catalog with some example data. To do that you need to start up catalog solr and then index the data.

```
docker-compose start catalog-solr
docker-compose exec catalog-solr bash /examples/load_into_solr.sh
```

Then start it

```
docker-compose up
```
In the browser go to `http://localhost:3000`

### Running Tests
```
docker-compose run --rm web bundle exec rspec
```

### Debugging
Puma doesn't always play nicely with pry.  Worker timeouts can end sessions early, and multi-threading can make taking input from the terminal troublesome.

To address these issues, the `script/docker-startup` file will run in WEBrick when started with the environment variable `RAILS_SERVER` set to webrick.

Changing environment variables in `docker-compose` gets updated when running `docker-compose up` so, to pick up environment variable changes every time, and attach for use with a debugger:

```
docker-compose up --no-start web && \
  docker-compose start web && \
  docker attach "$(docker-compose ps -q web)"
```

## Overview of Spectrum

Spectrum is the server-side support for [Search](https://github.com/mlibrary/search).  It is intended to mediate requests to solr and summon as a back-end interface to support library Search.

## Dependencies

* [spectrum-config](https://github.com/mlibrary/spectrum-config)

    * Spectrum-config handles individualized configuration of the targets searchable in the front-end.  It works a lot like a jello-mold.  Pour the user's request into it, get a tasty treat out.

* [spectrum-json](https://github.com/mlibrary/spectrum-json)

    * Spectrum-json handles receiving requests from end-users, applying any global normalization to the request, and passing it to the appropriate configuration to make a search against solr or summon.
    * Spectrum-json also handles things like taking actions on records, and identifying patron affiliation.
