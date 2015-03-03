FROM debian:jessie

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		docker.io \
		debootstrap

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh

