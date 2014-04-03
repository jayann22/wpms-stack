#!/bin/bash

sudo echo -e "# start apache on vagrant mounted\nstart on vagrant-mounted\nexec sudo service httpd start" > /etc/init/httpd.conf
