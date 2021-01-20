#!/bin/bash

ssh vagrant@127.0.0.1 -p 2222 -i ~/.ssh/test/id_rsa -i ~/.ssh/test/id_rsa-cert.pub -o StrictHostKeyChecking=no hostname 2> /dev/null
