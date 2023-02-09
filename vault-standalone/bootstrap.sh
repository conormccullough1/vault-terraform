#!/bin/bash

# Set environment variables. May need to redo this so that it also gets set for root in its home .bashrc directory
MY_IP=$(curl ifconfig.me)
export VAULT_ADDR='http://127.0.0.1:8200'
echo 'export VAULT_ADDR=http://127.0.0.1:8200' >> /home/ubuntu/.bashrc
echo "MY_IP=$(curl ifconfig.me)" >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

# Download, unzip, install and update packages
apt-get update -y
apt install jq -y
apt-get install unzip
wget https://releases.hashicorp.com/vault/1.12.2+ent/vault_1.12.2+ent_linux_amd64.zip
unzip vault_1.12.2+ent_linux_amd64.zip

# Create Vault directory and move files where they need to be
mv vault /usr/local/bin/ 
mkdir /opt/vault
mv /tmp/vault-license.hcl /opt/vault
mv /tmp/vault.service /etc/systemd/system

# Create the Vault configuration file
tee /opt/vault/vault-config.hcl <<EOF
disable_mlock = true
ui            = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

storage "raft" {
  path = "/opt/vault"
  node_id = "vault_1"
  # define system variable with \$(hostname -f) or something in user_data, then apply variable here for multi-node deployment:
#  node_id = vault_\${} or however HCL vars are referenced
}

# Again, add variable here for inter-node comms
cluster_addr = "http://127.0.0.1:8201"

api_addr = "http://$MY_IP:8200"

license_path = "/opt/vault/vault-license.hcl"
EOF

#source ~/.bashrc

# Update user permissions and add groups
useradd -r -s /bin/false vault && sudo addgroup vault && sudo usermod -a -G guest vault
chown -R vault:vault /opt/vault

# Configure and start the service
chown root:root /etc/systemd/system/vault.service
systemctl daemon-reload
systemctl enable vault.service
systemctl start vault.service

# Install Vault command autocomplete, initialise Vault, unseal Vault, and print the token to /tmp/VaultCreds.json
vault -autocomplete-install && source $HOME/.bashrc
vault operator init -key-shares=1 -key-threshold=1 -format=json > /tmp/VaultCreds.json
vault operator unseal $(cat /tmp/VaultCreds.json | jq -r .unseal_keys_b64[0])
export VAULT_TOKEN=$(cat /tmp/VaultCreds.json | jq -r .root_token)
