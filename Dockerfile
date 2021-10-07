FROM ruby:2.6

#Set up variables for creating a user to run the app in the container
ARG UID
ARG GID
ARG UNAME=app
ENV APP_HOME /app
ENV BUNDLE_PATH /bundle

#Create the group for the user
RUN if [ x"${GID}" != x"" ] ; \
    then groupadd ${UNAME} -g ${GID} -o ; \
    else groupadd ${UNAME} ; \
    fi

#Create the User and assign ${APP_HOME} as its home directory
RUN if [ x"${UID}" != x"" ] ; \
    then  useradd -m -d ${APP_HOME} -u ${UID} -o -g ${UNAME} -s /bin/bash ${UNAME} ; \
    else useradd -m -d ${APP_HOME} -g ${UNAME} -s /bin/bash ${UNAME} ; \
    fi

WORKDIR $APP_HOME

RUN mkdir -p ${BUNDLE_PATH} ${APP_HOME}/public ${APP_HOME}/tmp && chown -R ${UNAME} ${BUNDLE_PATH} ${APP_HOME}/public ${APP_HOME}/tmp

RUN gem install bundler:1.17.3

USER $UNAME

COPY Gemfile* ${APP_HOME}/
COPY local-gems/ ${APP_HOME}/local-gems/

RUN bundle install

COPY . ${APP_HOME}


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
