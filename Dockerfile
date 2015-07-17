FROM debian:jessie

RUN echo "deb http://http.debian.net/debian jessie-backports main"  >> /etc/apt/sources.list

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		docker.io \
		debootstrap \
		python \
		python-pip \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install awscli

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh
