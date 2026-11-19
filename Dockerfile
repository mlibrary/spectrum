########
# Base #
########
FROM ruby:4.0@sha256:4de17567bc750e8a509fd2181e5c5eda3137bbb635b046943277c90271e4ec1c AS base

#Set up variables for creating a user to run the app in the container
ARG UID=1000
ARG GID=1000
ARG UNAME=app
ARG RBSPY_VERSION=v0.55.0
ENV APP_HOME=/app
ENV BUNDLE_PATH=/bundle

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

RUN mkdir -p ${BUNDLE_PATH} ${APP_HOME}/public ${APP_HOME}/tmp \
 && chown -R ${UNAME} ${BUNDLE_PATH} ${APP_HOME}/public ${APP_HOME}/tmp

RUN curl -s -L https://github.com/rbspy/rbspy/releases/download/$RBSPY_VERSION/rbspy-x86_64-unknown-linux-gnu.tar.gz | \
  tar xzf - && \
  mv rbspy-x86_64-unknown-linux-gnu /usr/bin/rbspy && \
  chmod +x /usr/bin/rbspy

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb" ]

###############
# Development #
###############
FROM base AS development

USER $UNAME

##############
# Production #
##############
FROM base AS production
USER $UNAME

COPY --chown=${UNAME}:${UNAME} Gemfile* ${APP_HOME}/
COPY --chown=${UNAME}:${UNAME} local-gems/ ${APP_HOME}/local-gems/

RUN bundle install

COPY --chown=${UNAME}:${UNAME} . ${APP_HOME}

