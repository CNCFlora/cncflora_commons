#!/usr/bin/env bash

add-apt-repository ppa:brightbox/ruby-ng -y
apt-get update
apt-get upgrade -y
apt-get install wget curl git ruby2.1 ruby2.1-dev golang -y

gem install rspec

cd /opt
git clone https://github.com/coreos/etcd
cd etcd
./build

#echo "export GOROOT=/usr/lib/go" > /etc/rc.local
#echo "export GOBIN=/usr/bin/go" >> /etc/rc.local
echo 'nohup /opt/etcd/bin/etcd > /dev/null 2>&1 &' > /etc/rc.local

/etc/rc.local

