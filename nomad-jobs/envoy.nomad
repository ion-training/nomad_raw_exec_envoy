job "envoy" {
  datacenters = ["dc1"]
  task "envoy" {
    driver = "raw_exec"

    template {
      destination = "envoy_config.yml"
      data = file ("./envoy_config.yml")
    }

    artifact {
    source = "https://archive.tetratelabs.io/envoy/download/v1.20.0/envoy-v1.20.0-linux-amd64.tar.xz"
    }

    config {
      command = "/bin/bash"
      args    = ["-c", "local/envoy-v1.20.0-linux-amd64/bin/envoy -c ./envoy_config.yml" ]
    }

    resources {
      cpu = 250
      memory = 128
    }
  }
}