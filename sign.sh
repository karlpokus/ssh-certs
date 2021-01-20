#!/bin/bash

vault write -field=signed_key ssh-client-signer/sign/dev \
public_key=@$HOME/.ssh/test/id_rsa.pub > ~/.ssh/test/id_rsa-cert.pub

result=$?

if test $result -eq 0; then
  echo signed
  exit $result
fi
