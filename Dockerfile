FROM ruby:2.6
RUN mkdir -p /app/public /app/config/foci /secrets
WORKDIR /app

COPY Gemfile* /app/

RUN gem install bundler
RUN bundle install

COPY . /app

ARG SEARCH_VERSION=master
ARG PRIDE_VERSION=master
ARG BASE_URL=http://localhost:3000
ARG BIND_IP=0.0.0.0
ARG BIND_PORT=3000
ARG RAILS_ENV=production

ENV RAILS_RELATIVE_URL_ROOT=${BASE_URL}/spectrum \
    RAILS_ENV=${RAILS_ENV} \
    SPECTRUM_INST_LOCATION_FILES_DIR=config \
    SPECTRUM_SEARCH_GIT_BRANCH=${SEARCH_VERSION} \
    SPECTRUM_PRIDE_GIT_BRANCH=${PRIDE_VERSION} \
    REACT_APP_LOGIN_BASE_URL=${BASE_URL} \
    REACT_APP_SPECTRUM_BASE_URL=${BASE_URL}/spectrum \
    BIND_IP=${BIND_IP} \
    BIND_PORT=${BIND_PORT}

RUN ln -s /secrets/config--fields.yml config/fields.yml && \
  ln -s /secrets/config--aleph.yml config/aleph.yml && \
  ln -s /secrets/config--filters.yml config/filters.yml && \
  ln -s /secrets/config--instLocs.yaml config/instLocs.yaml && \
  ln -s /secrets/config--source.yml config/source.yml && \
  ln -s /secrets/config--keycard.yml config/keycard.yml && \
  ln -s /secrets/config--bookplates.yml config/bookplates.yml && \
  ln -s /secrets/config--facet_parents.yml config/facet_parents.yml && \
  ln -s /secrets/config--sorts.yml config/sorts.yml && \
  ln -s /secrets/config--foci--00-catalog.yml config/foci/00-catalog.yml && \
  ln -s /secrets/config--foci--01-articles.yml config/foci/01-articles.yml && \
  ln -s /secrets/config--foci--02-databases.yml config/foci/02-databases.yml && \
  ln -s /secrets/config--foci--03-journals.yml config/foci/03-journals.yml && \
  ln -s /secrets/config--foci--04-website.yml config/foci/04-website.yml && \
  ln -s /secrets/config--actions.yml config/actions.yml && \
  ln -s /secrets/config--skylight.yml config/skylight.yml && \
  ln -s /secrets/config--locColl.yaml config/locColl.yaml && \
  ln -s /secrets/config--specialists.yml config/specialists.yml && \
  ln -s /secrets/config--floor_locations.json config/floor_locations.json && \
  ln -s /secrets/config--get_this.yml config/get_this.yml && \
  ln -s /secrets/config--puma.rb config/puma.rb

CMD bundle exec rails s -b ${BIND_IP} -p ${BIND_PORT}
