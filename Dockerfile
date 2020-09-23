FROM node:14
RUN mkdir -p /app/tmp/search
WORKDIR /app/tmp/search

ARG SEARCH_VERSION=master
ARG HOST=localhost
ARG PROTO=http
ARG PORT=3000
ARG BIND_IP=0.0.0.0
ARG BIND_PORT=3000

ENV REACT_APP_LOGIN_BASE_URL=${PROTO}://${HOST}:${PORT} \
    REACT_APP_SPECTRUM_BASE_URL=${PROTO}://${HOST}:${PORT}/spectrum

RUN wget -q -O - https://github.com/mlibrary/search/archive/${SEARCH_VERSION}.tar.gz | \
  tar xzf - -C /app/tmp/search  --strip-components=1 && \
  npm install && \
  npm run build && \
  mv build/index.html build/app.html


FROM ruby:2.6
RUN mkdir -p /app/tmp /app/config/foci /secrets
WORKDIR /app
COPY . /app
COPY --from=0 /app/tmp/search /app/tmp/search
COPY --from=0 /app/tmp/search/build /app/public

ENV RAILS_RELATIVE_URL_ROOT=${PROTO}://${HOST}:${PORT}/spectrum \
    SPECTRUM_INST_LOCATION_FILES_DIR=config \
    SPECTRUM_SEARCH_GIT_BRANCH=${SEARCH_VERSION} \
    SPECTRUM_PRIDE_GIT_BRANCH=master \
    REACT_APP_LOGIN_BASE_URL=${PROTO}://${HOST}:${PORT} \
    REACT_APP_LOGIN_BASE_URL=${PROTO}://${HOST}:${PORT}/spectrum

RUN gem install bundler
RUN bundle install
RUN bundle exec rake assets:precompile
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
  ln -s /secrets/config--floor_locations.yml config/floor_locations.yml && \
  ln -s /secrets/config--get_this.yml config/get_this.yml

CMD bundle exec rails server --binding ${BIND_IP} --port ${BIND_PORT}
