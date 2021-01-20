# ssh-certs
This is a lab environment for ssh certificates. We'll use vault from hashicorp as a certificate authority and run a ssh server in a virtual machine with vagrant for testing.

# requirements
- vault
- vagrant

# usage
run vault with persistant storage on disk

````bash
$ vault server -config=vault/conf.hcl
export VAULT_ADDR='http://127.0.0.1:8200'
$ vault operator init > vault/secrets
$ vault login <root-token>
# mount the ssh secrets engine
$ vault secrets enable -path=ssh-client-signer ssh
# create ca keys
$ vault write ssh-client-signer/config/ca generate_signing_key=true
$ vault read -field=public_key ssh-client-signer/config/ca > trusted-user-ca-keys.pem
# create role
$ vault write ssh-client-signer/roles/dev @vault/dev.json
````

Now we're done with vault, let's create keys with `ssh-keygen` and put them in `~/.ssh/test`. Then sign them with the helper script `./sign.sh`.

Start vagrant with `vagrant up`. The server will only allow logins with signed ssh keys. See `Vagrantfile` for details.

Login with your signed keys. The signed keys are valid for 60 mins. Run `./sign.sh` to refresh them.

````bash
$ ssh vagrant@127.0.0.1 -p 2222 -i ~/.ssh/test/id_rsa -i ~/.ssh/test/id_rsa-cert.pub -o StrictHostKeyChecking=no
````

You can monitor and debug the sshd service with `sudo journalctl -u ssh -f`

# todos
- [x] prototype
- [ ] verify that principal in cert is actually checked
