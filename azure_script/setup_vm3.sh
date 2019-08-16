#!/usr/bin/env bash
sudo apt-get -y update       
#don't do apt-get upgrade because it does not work with AWS
sudo apt -y install libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev leafpad git xauth
sudo sysctl -w vm.nr_hugepages=128
git clone https://github.com/wilberdell/cloud/azure_script/setup_vm3.sh

cd cloud
azure_script/compile_and_config.sh







