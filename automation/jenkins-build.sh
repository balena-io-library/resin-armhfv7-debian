#!/bin/bash

# Jenkins build steps
docker build -t armv7hfdebian-mkimage .
docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`/qemu-arm-static:/usr/src/mkimage/qemu-arm-static armv7hfdebian-mkimage
docker push resin/armv7hf-debian
