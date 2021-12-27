# nomad_raw_exec_envoy
envoy started by nomad using raw_exec driver (using Vagrant)

# Topology
```
                                     
                                                    
                                        ###############
                                        #             #
                                        #             #
 `curl -sL http://192.168.56.71:9090` -->   ENVOY     #
                                        #             #
                                        # VM(Vagrant) #
                                        ###############
                                                    

```

# How to use this repo

Copy the repo and cd into it
```
git clone https://github.com:ion-training/nomad_raw_exec_envoy.git && nomad_raw_exec_envoy
```

Start the LAB
```
vagrant up --provision
```

Login
```
vagrant ssh
```

Change directory into /vagrant/nomad-jobs
```
cd /vagrant/nomad-jobs
```

Run envoy job
```
nomad job run envoy.nomad
```

Verify job status
```
nomad job status
```
```
nomad job status envoy
```

Test you can access envoy admin GUI
```
curl -fsSL localhost:9090 | head
```
```
curl -fsSL 192.168.56.71:9090 | head
```

Destroy the LAB
```
vagrant destroy -f
```

# Nomad Job Spec: ENVOY
raw_exec driver must be activated to be able to run this job.
```
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
```

# Caveats
Nomad binary is running using the nomad user.\

If for example envoy is started using standard ubuntu user (not using nomad), the envoy will create a file in /dev/shm.

Note the user and group:
```
$ ls -l /dev/shm/envoy_shared_memory_0 
-rw------- 1 ubuntu ubuntu 104 Dec 26 23:44 /dev/shm/envoy_shared_memory_0
```

Next if envoy process (using ubuntu user) is stopped and right after the nomad envoy job is started it will fail.\

### Workaround:
Delete manually the file using:
```
sudo rm /dev/shm/envoy_shared_memory_0
```

Note the user and group when running envoy with nomad
```
$ ls -l /dev/shm/envoy_shared_memory_0 
-rw------- 1 nomad nomad 104 Dec 26 23:50 /dev/shm/envoy_shared_memory_0
```
See also [LINK](https://github.com/envoyproxy/envoy/issues/4195)


# Sample output
```
$ nomad job run envoy.nomad
==> 2021-12-26T23:07:19Z: Monitoring evaluation "3ddd2e7c"
    2021-12-26T23:07:19Z: Evaluation triggered by job "envoy"
    2021-12-26T23:07:19Z: Evaluation within deployment: "952c8922"
    2021-12-26T23:07:19Z: Allocation "53dbaff4" created: node "c5befdff", group "envoy"
    2021-12-26T23:07:19Z: Evaluation status changed: "pending" -> "complete"
==> 2021-12-26T23:07:19Z: Evaluation "3ddd2e7c" finished with status "complete"
==> 2021-12-26T23:07:19Z: Monitoring deployment "952c8922"
  ✓ Deployment "952c8922" successful
    
    2021-12-26T23:07:41Z
    ID          = 952c8922
    Job ID      = envoy
    Job Version = 0
    Status      = successful
    Description = Deployment completed successfully
    
    Deployed
    Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
    envoy       1        1       1        0          2021-12-26T23:17:40Z
```
```
$ nomad job status
ID     Type     Priority  Status   Submit Date
envoy  service  50        running  2021-12-26T23:07:19Z
```

```
$ nomad job status envoy
ID            = envoy
Name          = envoy
Submit Date   = 2021-12-26T23:07:19Z
Type          = service
Priority      = 50
Datacenters   = dc1
Namespace     = default
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
envoy       0       0         1        0       0         0

Latest Deployment
ID          = 952c8922
Status      = successful
Description = Deployment completed successfully

Deployed
Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
envoy       1        1       1        0          2021-12-26T23:17:40Z

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created  Modified
53dbaff4  c5befdff  envoy       0        run      running  33s ago  12s ago
```

```
$ curl -fsSL localhost:9090 | head

<head>
  <title>Envoy Admin</title>
  <link rel='shortcut icon' type='image/png' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAH9SURBVEhL7ZRdTttAFIUrUFaAX5w9gIhgUfzshFRK+gIbaVbAzwaqCly1dSpKk5A485/YCdXpHTB4BsdgVe0bD0cZ3Xsm38yZ8byTUuJ/6g3wqqoBrBhPTzmmLfptMbAzttJTpTKAF2MWC7ADCdNIwXZpvMMwayiIwwS874CcOc9VuQPR1dBBChPMITpFXXU45hukIIH6kHhzVqkEYB8F5HYGvZ5B7EvwmHt9K/59CrU3QbY2RNYaQPYmJc+jPIBICNCcg20ZsAsCPfbcrFlRF+cJZpvXSJt9yMTxO/IAzJrCOfhJXiOgFEX/SbZmezTWxyNk4Q9anHMmjnzAhEyhAW8LCE6wl26J7ZFHH1FMYQxh567weQBOO1AW8D7P/UXAQySq/QvL8Fu9HfCEw4SKALm5BkC3bwjwhSKrA5hYAMXTJnPNiMyRBVzVjcgCyHiSm+8P+WGlnmwtP2RzbCMiQJ0d2KtmmmPorRHEhfMROVfTG5/fYrF5iWXzE80tfy9WPsCqx5Buj7FYH0LvDyHiqd+3otpsr4/fa5+xbEVQPfrYnntylQG5VGeMLBhgEfyE7o6e6qYzwHIjwl0QwXSvvTmrVAY4D5ddvT64wV0jRrr7FekO/XEjwuwwhuw7Ef7NY+dlfXpLb06EtHUJdVbsxvNUqBrwj/QGeEUSfwBAkmWHn5Bb/gAAAABJRU5'/>
  <style>
    .home-table {
      font-family: sans-serif;
      font-size: medium;
      border-collapse: collapse;
    }
```
