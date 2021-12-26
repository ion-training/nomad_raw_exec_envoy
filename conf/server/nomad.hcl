name = "nomad1"
datacenter = "dc1"
data_dir = "/opt/nomad"

bind_addr = "192.168.56.71"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true
  server_join {
    retry_join = [ "192.168.1.71"]
  }
  options {
    "driver.raw_exec.enable" = "1"
  }
}