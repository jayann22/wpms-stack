#!/usr/bin/env bash

sudo yum -y install git
mkdir /vagrant/www
cd /vagrant/
git clone -b release https://github.com/Link7/wp-multisite-stack.git
