#!/bin/bash

if [ x"$1" = x"" ] ; then
  SEARCH_VERSION=latest
else
  SEARCH_VERSION="$1"
fi

if [ x"$2" = x"" ] ; then
  NAMESPACE="testing-1"
else
  NAMESPACE="$2"
fi

docker \
  build \
  -t "bertrama/spectrum:${NAMESPACE}-$(git describe --tags --abbrev=0)--${SEARCH_VERSION}" \
  -t "bertrama/spectrum:${NAMESPACE}-latest--${SEARCH_VERSION}" \
  --build-arg SEARCH_VERSION=${SEARCH_VERSION} \
  .
