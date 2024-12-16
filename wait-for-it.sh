#!/usr/bin/env bash
# Use this script to test if a given TCP host/port are available

set -e

TIMEOUT=15
QUIET=0
HOST=""
PORT=""

echoerr() {
  if [ "$QUIET" -ne 1 ]; then echo "$@" 1>&2; fi
}

usage() {
  cat <<EOF
Usage:
  $0 host:port [-t timeout] [-- command args]
  -q | --quiet                        Do not output any status messages
  -t TIMEOUT | --timeout=timeout      Timeout in seconds, zero for no timeout
  -- COMMAND ARGS                     Execute command with args after the test finishes
EOF
  exit 1
}

wait_for() {
  for i in $(seq $TIMEOUT); do
    nc -z "$HOST" "$PORT" > /dev/null 2>&1 && return 0
    sleep 1
  done
  echo "Operation timed out" >&2
  exit 1
}

while [[ $# -gt 0 ]]
do
  case "$1" in
    *:* )
    HOST=$(printf "%s\n" "$1"| cut -d : -f 1)
    PORT=$(printf "%s\n" "$1"| cut -d : -f 2)
    shift 1
    ;;
    -q | --quiet)
    QUIET=1
    shift 1
    ;;
    -t)
    TIMEOUT="$2"
    shift 2
    ;;
    --timeout=*)
    TIMEOUT="${1#*=}"
    shift 1
    ;;
    --)
    shift
    exec "$@"
    ;;
    *)
    usage
    ;;
  esac
done

if [[ "$HOST" == "" || "$PORT" == "" ]]; then
  echo "Error: you need to provide a host and port to test." >&2
  usage
fi

wait_for