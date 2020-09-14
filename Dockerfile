FROM node:14
RUN mkdir -p /app/tmp/search
WORKDIR /app/tmp/search
RUN wget -q -O - https://github.com/mlibrary/search/archive/master.tar.gz | \
  tar xzf - -C /app/tmp/search  --strip-components=1 && \
  npm install && \
  npm run build


FROM ruby:2.6
RUN mkdir -p /app/tmp
WORKDIR /app
COPY . /app
COPY --from=0 /app/tmp/search /app/tmp/search
COPY --from=0 /app/tmp/search/build /app/public
ADD local-dev.tar /app

RUN gem install bundler
RUN bundle install
RUN bundle exec rake assets:precompile
CMD bundle exec puma
