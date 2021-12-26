#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# pre-reqs
# apt-get update
# apt-get install -y zip unzip

# hashicorp apt repo
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# install nomad
apt-get update
apt-get install -y nomad
hash -r

# create directories
mkdir -p /opt/nomad
mkdir -p /etc/nomad.d

chmod 700 /opt/nomad
chmod 700 /etc/nomad.d

cp -ap /vagrant/conf/server/nomad.hcl /etc/nomad.d/
chown -R nomad: /etc/nomad.d /opt/nomad/

cp -ap /vagrant/conf/nomad.service /etc/systemd/system/

# nomad set bash env
cp -ap /vagrant/conf/nomad-bash-env.sh /etc/profile.d/

# Display nomad info on login
echo 'echo '$ nomad server members''  >> /etc/profile
echo "nomad server members" >> /etc/profile
echo "echo ' '"  >> /etc/profile

echo 'echo '$ nomad node status -verbose'' >> /etc/profile
echo "nomad node status -verbose" >> /etc/profile
echo "echo ' '"  >> /etc/profile

systemctl enable nomad
systemctl start nomad
