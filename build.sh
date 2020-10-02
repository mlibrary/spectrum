#!/bin/bash

docker \
  build \
  -t "bertrama/spectrum:$(git describe --tags --abbrev=0)" \
  -t "bertrama/spectrum:latest" \
  .
