FROM python:alpine as builder

MAINTAINER Adiel Cristo <adiel@adielcristo.com>

# Install dependencies and tools
RUN apk add --no-cache --update --virtual .build-deps \
    autoconf \
    g++ \
    git \
    make

WORKDIR "/var/www"

COPY ./.requirements.txt _build/

RUN pip install --upgrade \
        pip \
        wheel==0.29.0 && \
    pip install -r \
        _build/.requirements.txt
