
# sops
## add new host
1. execute `ssh root@<ip-address> "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age`
2. edit .sops.yaml adding the result to keys: key and updating the creation_rules section.
3. run `sops updatekeys ./secrets/secrets.yaml`
