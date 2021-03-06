#!/bin/bash
set -e

create_ssldb() {
    /usr/lib/squid/ssl_crtd -c -s /var/spool/squid3_ssldb
    chown -R ${SQUID_USER}:${SQUID_USER} /var/spool/squid3_ssldb
}

create_log_dir() {
  mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  mkdir -p ${SQUID_CACHE_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

apply_backward_compatibility_fixes() {
  if [[ -f /etc/squid3/squid.user.conf ]]; then
    rm -rf /etc/squid3/squid.conf
    ln -sf /etc/squid3/squid.user.conf /etc/squid3/squid.conf
  fi
}

create_log_dir
create_cache_dir
apply_backward_compatibility_fixes
create_ssldb

# allow arguments to be passed to squid3
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f /etc/squid3/squid.conf -z
  fi
  echo "Starting squid..."
  exec $(which squid) -f /etc/squid3/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
