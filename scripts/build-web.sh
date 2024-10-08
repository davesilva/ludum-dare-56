#!/bin/sh

mkdir -p $(dirname "$0")/../build/web
docker run --rm \
  --volume .:/root/src \
  --tmpfs /root/src/.config \
  --workdir /root/src \
  davesilva/godot-ci:3.5.3 \
  godot --no-window --verbose --export "HTML5" build/web/index.html
