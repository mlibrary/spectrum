FROM ruby:4.0-slim

ENV APP_HOME /app
WORKDIR $APP_HOME

RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

COPY Gemfile* ${APP_HOME}/
RUN bundle install

COPY . ${APP_HOME}

ENV SPECTRUM_BASE_URL=http://web:3000

ENTRYPOINT ["ruby", "server.rb"]
