#!/bin/bash

ROLE=$1 # dev nottl

if test -z $ROLE; then
  echo "error: missing ROLE arg at pos 1"
  exit 1
fi

vault write -field=signed_key ssh-client-signer/sign/$ROLE \
public_key=@$HOME/.ssh/test/id_rsa.pub > ~/.ssh/test/id_rsa-cert.pub

result=$?
if test $result -eq 0; then
  echo signed
  exit $result
fi
