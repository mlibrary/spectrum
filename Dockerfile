########
# Base #
########
FROM ruby:3.3 as base

#Set up variables for creating a user to run the app in the container
ARG UID=1000
ARG GID=1000
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

RUN curl -s -L https://github.com/rbspy/rbspy/releases/download/v0.33.0/rbspy-x86_64-unknown-linux-gnu.tar.gz | \
  tar xzf - && \
  mv rbspy-x86_64-unknown-linux-gnu /usr/bin/rbspy && \
  chmod +x /usr/bin/rbspy

CMD bundle exec puma -C config/puma.rb

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

