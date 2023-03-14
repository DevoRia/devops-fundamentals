#!/bin/bash

function count_files {
  local DIR="$1"
  local COUNT=$(find "$DIR" -type f | wc -l)
  echo "$DIR: $COUNT"
}

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [DIRECTORY ...]"
  exit 1
fi

for DIR in "$@"; do
  count_files "$DIR"
done
