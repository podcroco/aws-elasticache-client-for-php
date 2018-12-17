#!/bin/bash

cd /tmp
mkdir libmemcached
git clone https://github.com/awslabs/aws-elasticache-cluster-client-libmemcached.git
cd aws-elasticache-cluster-client-libmemcached
mkdir BUILD
touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
cd BUILD
../configure --prefix=/tmp/libmemcached --with-pic
make
make install

cd /tmp
git clone https://github.com/awslabs/aws-elasticache-cluster-client-memcached-for-php.git
cd aws-elasticache-cluster-client-memcached-for-php
git checkout php7
phpize
./configure --with-libmemcached-dir=/tmp/libmemcached --enable-memcached-igbinary --enable-memcached-json --enable-memcached-msgpack --disable-memcached-sasl
patch -p1 < /tmp/php73.patch
sed -i "s#-lmemcached#/tmp/libmemcached/lib/libmemcachedutil.a /tmp/libmemcached/lib/libmemcached.a -lcrypt -lpthread -lm -lstdc++#" Makefile
sed -i "s#-lmemcachedutil##" Makefile
sed -i "s#-L/tmp/libmemcached/lib##" Makefile
make
make install
cp /tmp/aws-elasticache-cluster-client-memcached-for-php/modules/memcached.so /build

