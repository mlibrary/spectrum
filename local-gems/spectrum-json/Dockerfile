FROM ruby:2.6.6

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https\
  nodejs

WORKDIR /app

COPY ./ /app

RUN gem install bundler -v ">= 1.3, < 2.0"
ENV BUNDLE_PATH /gems
