#!/bin/bash


# this script is intended to be run on an empty server, 
# it will install git and clone the wpms-stack repo,
# and after that it will run the install.sh script

# login to your server and run the following command to get it started
# curl https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/scripts/serverinstall.sh | sudo bash



# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ ! `rpm -qa | grep rpmforge` ]]
then

 echo -e "Installing and enabling rpmforge extras repository..."
 rpm -i 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm'
  if [[ $? -ne 0 ]]
  then
   echo -e "echo failed to install rpmforge repos"
   exit 1
  fi
 rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
 if [[ $? -ne 0 ]]
  then
   echo -e "echo failed to install rpmforge repos"
   exit 1
  fi

 sed -i '15,20s/enabled = 0/enabled = 1/' /etc/yum.repos.d/rpmforge.repo
  if [[ $? -ne 0 ]]
  then
   echo -e "echo failed to install rpmforge repos"
   exit 1
  fi

fi

echo -e "Installing git...\n"
yum install -y git
if [[ $? -ne 0 ]]
  then
   echo -e "echo failed to install git"
   exit 1
fi

echo -e "cloning wpms-stack repo...\n"
git clone https://github.com/Link7/wpms-stack.git /var/wpms-stack


echo -e "please run the following command: $ cd wpms-stack/setup && sudo ./install.sh"

