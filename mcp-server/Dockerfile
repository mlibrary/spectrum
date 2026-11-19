FROM ruby:4.0@sha256:4de17567bc750e8a509fd2181e5c5eda3137bbb635b046943277c90271e4ec1c AS base

ENV APP_HOME /app
WORKDIR $APP_HOME

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential \
 && apt-get upgrade -y \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY Gemfile* ${APP_HOME}/
RUN bundle install

COPY . ${APP_HOME}
RUN chmod +x bin/docker-entrypoint

ENV SPECTRUM_BASE_URL=http://web:3000

# MCP_TRANSPORT=stdio (default) or http
ENTRYPOINT ["bin/docker-entrypoint"]
