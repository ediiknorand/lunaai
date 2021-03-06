#! /bin/bash

if [ $# -lt 3 ]; then
  echo "Usage: $0 CHAT_FILE CHAR_NAME SAVE_DIR"
  exit 1
else
  CHAT_FILE=$1
  CHAR_NAME=$2
  SAVE_DIR=$3
fi

while true; do cat $CHAT_FILE | tr -d '\r' | sed s"/|00//" | grep "^$CHAR_NAME : \\^" | tr -d "^" | tail -1 | cut -d":" -f2- | ./parser "$SAVE_DIR"; done
