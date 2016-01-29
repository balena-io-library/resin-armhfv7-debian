FROM debian:jessie

RUN apt-get -q update \
	&& apt-get -qy install \
		curl \
		debootstrap \
		python \
		python-pip \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN pip install awscli

COPY . /usr/src/mkimage

WORKDIR /usr/src/mkimage

CMD ./build.sh
