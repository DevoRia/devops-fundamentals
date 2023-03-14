#!/bin/bash


THRESHOLD=10 # GB

if [[ $# -eq 1 ]]; then
  THRESHOLD=$1
fi

while true; do
  FREE_SPACE=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')

  if [[ $FREE_SPACE -lt $THRESHOLD ]]; then
    echo "WARNING: Free disk space is below ${THRESHOLD}GB!"
  fi

  sleep 60
done
