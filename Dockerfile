FROM debian:jessie

RUN echo "deb http://http.debian.net/debian jessie-backports main"  >> /etc/apt/sources.list

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		docker.io \
		debootstrap

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh
