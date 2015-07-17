#!/bin/bash

# Jenkins build steps
docker build -t armv7hfdebian-mkimage .
docker run --privileged -e REGION_NAME=$REGION_NAME -e ACCESS_KEY=$ACCESS_KEY -e SECRET_KEY=$SECRET_KEY -e BUCKET_NAME=$BUCKET_NAME -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`/qemu-arm-static:/usr/src/mkimage/qemu-arm-static armv7hfdebian-mkimage
docker push resin/armv7hf-debian
