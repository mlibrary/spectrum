FROM ruby:4.0-slim

ENV APP_HOME /app
WORKDIR $APP_HOME

RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

COPY Gemfile* ${APP_HOME}/
RUN bundle install

COPY . ${APP_HOME}
RUN chmod +x bin/docker-entrypoint

ENV SPECTRUM_BASE_URL=http://web:3000

# MCP_TRANSPORT=stdio (default) or http
ENTRYPOINT ["bin/docker-entrypoint"]
