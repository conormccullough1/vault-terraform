# Dummy config file for reference

disable_mlock = true
ui            = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

storage "raft" {
  path = "/opt/vault"
  node_id = "vault_1"
  # define system variable with '$(hostname -f)' or something in `user_data`, then apply variable here for multi-node deployment:
#  node_id = "vault_${}" or however HCL vars are referenced
}

# Again, add variable here for inter-node comms
cluster_addr = "http://127.0.0.1:8201"

api_addr = "http://public_ip_here:8200"

license_path = "/opt/vault/vault-license.hcl"
