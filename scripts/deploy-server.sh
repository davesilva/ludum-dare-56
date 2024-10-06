#!/bin/sh

source $(dirname "$0")/docker-build.sh
ssh root@ld56.dmsilva.com -t "echo $(git rev-parse --short HEAD) > /root/CURRENT_REV && ./docker-restart.sh"

