FROM alpine:3.16 AS base-image
ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:ja" LC_ALL="ja_JP.UTF-8"
RUN set -xe \
    && apk update \
    && apk add curl tzdata \
    && cat /usr/share/zoneinfo/Asia/Tokyo > /etc/localtime
COPY alpine-libmemcached.patch /tmp/
RUN set -xe \
    && apk add \
        php81-dev \
        openssl-dev \
        cyrus-sasl-dev \
        libevent-dev gcc g++ git make patch autoconf
RUN ln -s /usr/bin/phpize81 /usr/bin/phpize \
    && ln -s /usr/bin/php81 /usr/bin/php \
    && ln -s /usr/bin/php-config81 /usr/bin/php-config
RUN cd /tmp/ \
    && git clone https://github.com/awslabs/aws-elasticache-cluster-client-libmemcached.git \
    && cd aws-elasticache-cluster-client-libmemcached \
    && patch -p1 < /tmp/alpine-libmemcached.patch \
    && touch configure.ac aclocal.m4 configure Makefile.am Makefile.in \
    && mkdir BUILD \
    && cd BUILD \
    && ../configure --prefix=/tmp/libmemcached --with-pic \
    && make && make install
RUN cd /tmp \
    && git clone https://github.com/awslabs/aws-elasticache-cluster-client-memcached-for-php \
    && cd aws-elasticache-cluster-client-memcached-for-php \
    && git checkout php8.x \
    && phpize \
    && mkdir BUILD \
    && cd BUILD \
    && ../configure --with-libmemcached-dir=/tmp/libmemcached \
    && sed -i "s#-L/tmp/libmemcached/lib##" Makefile \
    && sed -i "s#-lmemcachedutil##" Makefile \
    && sed -i "s#-lmemcached#/tmp/libmemcached/lib/libmemcachedutil.a /tmp/libmemcached/lib/libmemcached.a -lcrypt -lpthread -lm -lstdc++#" Makefile \
    && make && make install
RUN cp /usr/lib/php81/modules/memcached.so /build

