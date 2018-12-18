FROM centos:centos7.6.1810

RUN yum -y install epel-release \
    && rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
    && yum install -y --enablerepo=remi --enablerepo=remi-php72 \
       php php-devel php-pecl-igbinary-devel php-pecl-msgpack-devel zlib-devel git make file patch

COPY build.sh /tmp
#COPY php73.patch /tmp

CMD /bin/bash /tmp/build.sh
