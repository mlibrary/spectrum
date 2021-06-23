FROM ruby:2.6

#Set up variables for creating a user to run the app in the container
ARG UNAME=app
ENV APP_HOME /app
ENV BUNDLE_PATH /bundle

#Create the group for the user
RUN groupadd ${UNAME}

#Create the User and assign ${APP_HOME} as its home directory
RUN useradd -m -d ${APP_HOME} -g ${UNAME} -s /bin/bash ${UNAME}

WORKDIR $APP_HOME

RUN mkdir -p ${BUNDLE_PATH} ${APP_HOME}/public ${APP_HOME}/tmp && chown -R ${UNAME} ${APP_HOME}/public ${APP_HOME}/tmp


COPY Gemfile* ${APP_HOME}/

RUN gem install bundler:1.17.3
RUN bundle install

COPY . ${APP_HOME}

USER $UNAME

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

CMD bundle exec rails s -b ${BIND_IP} -p ${BIND_PORT}
