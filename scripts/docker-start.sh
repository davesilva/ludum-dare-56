#!/bin/sh

docker run --name ld56 --rm --platform linux/x86_64 -p 10568:10568 davesilva/ludum-dare-56:$(git rev-parse --short HEAD)
docker stop ld56

