# How-To

This provisions a standalone Vault instance with a Raft back-end.

`bootstrap.sh` automatically configures, initialises and unseals Vault, so it should be ready to go out of the box.

Each value marked 'CHANGEME' needs to be modified prior to running:

1. A license key needs to be added
2. You need to actually create the key in AWS
3. The path needs to be updated to point towards the location of the key on your local machine

# An Important Note

The security groups defined in `networks.tf` are completely open to the world. If you intend on running Vault for more than an hour or so, modify these to only include your own public IP/The IP addresses of those using the instance.

