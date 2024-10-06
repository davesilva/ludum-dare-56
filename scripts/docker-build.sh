#!/bin/sh

docker build --platform linux/x86_64 -t davesilva/ludum-dare-56:$(git rev-parse --short HEAD) .
docker push davesilva/ludum-dare-56:$(git rev-parse --short HEAD)

