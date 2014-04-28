#!/bin/bash


# can download & execute this script on your server with the following command 
# $ curl https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/scripts/gitinstall.sh | sudo bash

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


# clone wpms-stack repo onto server
git clone --bare https://github.com/Link7/wpms-stack.git /var/wpms-stack.git

# create location where repo will be checked out
git init /var/wpms-stack

# add server git repo as remote to checked out dir
cd /var/wpms-stack
git remote add hub /var/wpms-stack.git
git pull hub master



# setup git hooks

FILE="/var/wpms-stack.git/hooks/post-update"

/bin/cat <<EOM >$FILE
#!/bin/sh

echo
echo "**** Pulling changes into Prime [Hub's post-update hook]"
echo

cd /var/wpms-stack || exit
unset GIT_DIR
git pull hub master

exec git-update-server-info
EOM

chmod +x $FILE


FILE="/var/wpms-stack/.git/hooks/post-commit"

/bin/cat <<EOM >$FILE

#!/bin/sh

echo
echo "**** pushing changes to Hub [Prime's post-commit hook]"
echo

git push hub
EOM

chmod +x $FILE

# user can now push-pull from server repo through ssh
# server repo url is: ssh://USER@SERVERIP:PORT/var/wpms-stack.git
# when you push to that url it will be update the server
# when you update somethin on the server itself and commit it 
# you can then also pull the changes to your local from the server


