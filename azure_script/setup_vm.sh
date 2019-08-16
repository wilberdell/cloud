#!/usr/bin/env bash
sudo apt-get -y update       
sudo apt-get -y upgrade  
sudo apt -y install libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev leafpad git xauth
git clone https://https://github.com/wilberdell/cloud

cd cloud
azure_script/compile_and_config.sh
cd bin
./xmr-stak







