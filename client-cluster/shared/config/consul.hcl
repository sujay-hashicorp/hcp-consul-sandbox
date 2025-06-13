log_level = "INFO"
data_dir = "/opt/consul/data"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "IP_ADDRESS"
retry_join = ["RETRY_JOIN"]
datacenter = "DATACENTER_NAME"

acl {
  enabled = true
  tokens {
    agent = "CONSUL_HTTP_TOKEN"
  }
}
license_path = "/etc/consul.d/license.hclic"

ports {
  grpc_tls = 8502
}

encrypt = "ENCRYPTION_KEY"

tls {
  defaults {
    ca_file               = "/ops/shared/certs/ca.pem"
    verify_incoming       = false
    verify_outgoing       = true
    verify_server_hostname = false
  }
}
