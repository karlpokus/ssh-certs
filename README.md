# ssh-certs
This is a lab environment for ssh certificates. We'll use vault from hashicorp as a certificate authority and run a ssh server in a virtual machine with vagrant for testing.

# requirements
- vault
- vagrant
- ssh-keygen

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

Now we're done with vault, let's create keys with `ssh-keygen` and put them in `~/.ssh/test`. Then sign them with the helper script `./sign.sh dev`.

Start vagrant with `vagrant up`. The server will only allow logins with signed ssh keys. See `Vagrantfile` for details.

Login with your signed keys. The signed keys are valid for 60 mins. Run `./sign.sh dev` to refresh them.

````bash
$ ssh vagrant@127.0.0.1 -p 2222 -i ~/.ssh/test/id_rsa -i ~/.ssh/test/id_rsa-cert.pub -o StrictHostKeyChecking=no
````

You can monitor and debug the sshd service with `sudo journalctl -u ssh -f`

# cert expiration
The cert expiration setting is handled by the fields `ttl` and `max_ttl` in the vault role specification. One would think allowed values would correspond to the ones under the -V flag for [ssh-keygen](https://man.openbsd.org/ssh-keygen.1#V) but that is not true. Vault deems these values invalid: always, forever, 0 (translates to 1 month), 19700101:20501212. The error message `error converting input forever for field "ttl": strconv.ParseInt: parsing "forever": invalid syntax` suggests only ints allowed but I suspect the parser is time.ParseDuration in go.

````bash
# create new role
$ vault write ssh-client-signer/roles/nottl @vault/nottl.json
# verify the contents of the role
$ vault read ssh-client-signer/roles/nottl
# sign the keys
$ ./sign.sh nottl
# verify login works
$ ./check.sh
# verify contents of cert
$ ssh-keygen -L -f ~/.ssh/test/id_rsa-cert.pub
````

Verify that sshd checks expiration date properly.

````bash
# disable time synchronisation
$ VBoxManage setextradata <vm_id> "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1
$ vagrant reload
$ sudo date -s '2000-01-01'
````

Create a ca that allows user certs with no expiration date (requires yolo/ca.pub in trusted-user-ca-keys.pem on the host)

````bash
# create ca keys
$ ssh-keygen -C ca -f yolo/ca
# sign the test keys
$ ssh-keygen -s yolo/ca -I cf -n vagrant -V "always:forever" -z 1 ~/.ssh/test/id_rsa.pub
````

# todos
- [x] prototype
- [x] revert disallowing AuthorizedKeysFile
- [x] tweak cert expiration date
- [ ] verify that principal in cert is actually checked
- [x] verify cert start date
- [ ] no expiry
