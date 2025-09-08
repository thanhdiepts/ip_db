#!/bin/bash
# Usage: ./nsupdate.sh <name> <type> <value> [server]

KEYFILE="/etc/powerdns/ddns.key"
SERVER="${4:-127.0.0.1}"   # Default server is localhost
TTL=600                    # Adjust TTL as needed

if [ $# -lt 3 ]; then
  echo "Usage: $0 <name> <type> <value> [server]"
  exit 1
fi

NAME=$1
TYPE=$2
VALUE=$3

# Run nsupdate
OUTPUT=$(nsupdate -k "$KEYFILE" <<EOF 2>&1
server $SERVER
update delete $NAME $TYPE
update add $NAME $TTL $TYPE $VALUE
send
EOF
)
STATUS=$?

if [ $STATUS -eq 0 ]; then
  echo "DNS update command sent successfully"
  # Optional verify with dig
  dig @$SERVER "$NAME" "$TYPE" +short | grep -q "$VALUE"
  if [ $? -eq 0 ]; then
    echo "Record verified: $NAME $TYPE $VALUE"
  else
    echo "Update sent, but record not verified yet"
  fi
else
  echo "DNS update failed"
  echo "Details:"
  echo "$OUTPUT"
fi
