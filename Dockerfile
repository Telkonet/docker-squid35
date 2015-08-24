FROM        debian:jessie
MAINTAINER  btomasik@telkonet.com

###
# Maintain ENV variables originally found from
# sameersbn/docker-squid
###
ENV SQUID35_VERSION 3.5.7
ENV SQUID_CACHE_DIR /var/spool/squid3
ENV SQUID_LOG_DIR   /var/log/squid3
ENV SQUID_USER      proxy

###
# Update the container
###
RUN         apt-get update && apt-get upgrade -qq

# Install required applications/libraries
RUN         apt-get install --no-install-recommends -qq \
                build-essential \
                libssl-dev \
                wget

# Setup source directory
RUN         mkdir -p /usr/src
WORKDIR     /usr/src
RUN         wget --quiet http://www.squid-cache.org/Versions/v3/3.5/squid-${SQUID35_VERSION}.tar.gz
RUN         tar -xzf squid-${SQUID35_VERSION}.tar.gz && rm -f squid-${SQUID35_VERSION}.tar.gz

# Copy in the entrypoint program
COPY        entrypoint.sh /sbin/entrypoint.sh
RUN         chmod 755 /sbin/entrypoint.sh

EXPOSE      3128/tcp
VOLUME      [ "${SQUID_CACHE_DIR}" ]
ENTRYPOINT  [ "/sbin/entrypoint.sh" ]

# Configure the squid build as desired
RUN         cd /usr/src/squid-${SQUID35_VERSION} && ./configure \
                --prefix=/usr \
                --localstatedir=/var \
                --libexecdir=/usr/lib/squid \
                --srcdir=. \
                --datadir=/usr/share/squid \
                --sysconfdir=/etc/squid \
                --with-default-user=${SQUID_USER} \
                --with-logdir=${SQUID_LOG_DIR} \
                --with-pidfile=/var/run/squid.pid \
                --enable-icmp \
                --enable-delay-pools \
                --enable-icap-client \
                --enable-wccp \
                --enable-wccpv2 \
                --enable-snmp \
                --enable-linux-netfilter \
                --enable-follow-x-forwarded-for \
                --enable-ssl-crtd \
                --enable-auth-negotiate=none \
                --enable-external-acl-helpers=none \
                --disable-ipv6 \
                --with-openssl \
                --with-large-files

# Perform squid compliation & installation
RUN     cd /usr/src/squid-${SQUID35_VERSION} && make && make install
