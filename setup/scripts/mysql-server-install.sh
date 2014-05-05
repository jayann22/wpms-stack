#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TERM=linux

nocol="\033[0m"
red="\033[31m"
green="\033[032m"
cyan="\033[36m"
yellow="\033[33m"

config=".my.cnf.$$"
command=".mysql.$$"
mysql_client=""

trap "interrupt" 1 2 3 6 15

rootpass=""
echo_n=
echo_c=

set_echo_compat() {
    case `echo "testing\c"`,`echo -n testing` in
	*c*,-n*) echo_n=   echo_c=     ;;
	*c*,*)   echo_n=-n echo_c=     ;;
	*)       echo_n=   echo_c='\c' ;;
    esac
}

prepare() {
    touch $config $command
    chmod 600 $config $command
}

find_mysql_client() {
  for n in ./bin/mysql mysql
  do
    $n --no-defaults --help > /dev/null 2>&1
    status=$?
    if test $status -eq 0
    then
      mysql_client=$n
      return
    fi
  done
  echo -e ""$red"Can't find a 'mysql' client in PATH or ./bin"$nocol""
  exit 1
}

do_query() {
    echo "$1" >$command
    #sed 's,^,> ,' < $command  # Debugging
    $mysql_client --defaults-file=$config <$command
    return $?
}

basic_single_escape () {
    # The quoting on this sed command is a bit complex.  Single-quoted strings
    # don't allow *any* escape mechanism, so they cannot contain a single
    # quote.  The string sed gets (as argv[1]) is:  s/\(['\]\)/\\\1/g
    #
    # Inside a character class, \ and ' are not special, so the ['\] character
    # class is balanced and contains two characters.
    echo "$1" | sed 's/\(['"'"'\]\)/\\\1/g'
}

make_config() {
    echo "# mysql_secure_installation config file" >$config
    echo "[mysql]" >>$config
    echo "user=root" >>$config
    esc_pass=`basic_single_escape "$rootpass"`
    echo "password='$esc_pass'" >>$config
    #sed 's,^,> ,' < $config  # Debugging
}

mysql_install(){
if [[ ! `rpm -qa | grep mysql-server` ]]
        then
         yum install mysql-server -y && service mysqld start | grep Starting && chkconfig mysqld on		 
        else
         echo -e ""$red"mysql-server is already installed"$nocol""
        fi
}

get_root_password() {
    status=1
    while [ $status -eq 1 ]; do
        stty -echo
        echo -e $echo_n ""$green"Enter current password for root (enter for none):"$nocol" $echo_c"
        read password
        echo -e
        stty echo
        if [ "x$password" = "x" ]; then
            hadpass=0
        else
            hadpass=1
        fi
        rootpass=$password
        make_config
        do_query ""
        status=$?
    done
    echo -e ""$green"OK, successfully used password, moving on..."$nocol""
    echo -e
}

set_root_password() {
    stty -echo
    echo -e $echo_n ""$green"New password:"$nocol" $echo_c"
    read password1
    echo -e
    echo -e $echo_n ""$green"Re-enter new password:"$nocol" $echo_c"
    read password2
    echo -e
    stty echo

    if [ "$password1" != "$password2" ]; then
        echo -e ""$red"Sorry, passwords do not match."$nocol""
        echo -e
        return 1
    fi

    if [ "$password1" = "" ]; then
        echo -e ""$red"Sorry, you can't use an empty password here."$nocol""
        echo -e
        return 1
    fi

    esc_pass=`basic_single_escape "$password1"`
    do_query "UPDATE mysql.user SET Password=PASSWORD('$esc_pass') WHERE User='root';"
    if [ $? -eq 0 ]; then
        echo -e ""$cyan"Password updated successfully!"$cyan""
        echo -e ""$cyan"Reloading privilege tables..."$nocol""
        reload_privilege_tables
        if [ $? -eq 1 ]; then
                clean_and_exit
        fi
        echo -e
        rootpass=$password1
        make_config
    else
        echo -e ""$red"Password update failed!"$nocol""
        clean_and_exit
    fi

    return 0
}

remove_anonymous_users() {
    do_query "DELETE FROM mysql.user WHERE User='';"
    if [ $? -eq 0 ]; then
	echo -e ""$cyan" ... Success!"$nocol""
    else
	echo -e ""$red" ... Failed!"$nocol""
	clean_and_exit
    fi

    return 0
}

remove_remote_root() {
    do_query "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    if [ $? -eq 0 ]; then
	echo -e " "$cyan"... Success!"$nocol""
    else
	echo -e " "$red"... Failed!"$nocol""
    fi
}

remove_test_database() {
    echo -e " - "$cyan"Dropping test database..."$nocol""
    do_query "DROP DATABASE test;"
    if [ $? -eq 0 ]; then
	echo -e ""$cyan" ... Success!"$nocol""
    else
	echo -e " "$red"... Failed!  Not critical, keep moving..."$nocol""
    fi

    echo -e " "$cyan"- Removing privileges on test database..."$nocol""
    do_query "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    if [ $? -eq 0 ]; then
	echo -e " "$cyan"... Success!"$nocol""
    else
	echo -e " "$red"... Failed!  Not critical, keep moving..."$nocol""
    fi

    return 0
}

add_remote_user() {
    	
	while :
	do
	echo -e $echo_n ""$green"Add username which will be used for remote access(default 'admin'):"$nocol" $echo_c"
    read username
	
	if [ -z $username ]; then
    break
	fi
	
	if [[ $username =~ ^[a-z]+$ ]]; then
	break
	fi
	
	done
	
	if [ -z $username ]; then
	username=admin
	fi
	
	while :
	do
	echo -e $echo_n ""$green"Add hostname which will be used for remote access(default '%'):"$nocol" $echo_c"
    read hostname
	
	if [ -z $hostname ]; then
    break
	fi
	
	if [[ $hostname =~ ^[a-z]+$ ]]; then
	break
	fi
	
	done
	
	if [ -z $hostname ]; then
	hostname=%
	fi
	
    do_query "create user '$username'@'$hostname' identified by '';"
	do_query "grant all privileges on *.* to '$username'@'$hostname' with grant option;"
    if [ $? -eq 0 ]; then
	    echo -e ""$cyan"Reloading privilege tables..."$nocol""
        reload_privilege_tables
		reload_hosts_tables
		echo -e ""$cyan"User successfully added!"$nocol""
        echo -e
        remuser=$username
        make_config
    else
        echo -e ""$red"Remote user creation failed!"$nocol""
    fi

    return 0
}

set_remote_user_password() {
    echo -e ""$green"Set password or leave blank, I will generate randomly!"$nocol""
	stty -echo
    echo -e $echo_n ""$green"Set remote user password:"$nocol" $echo_c"
    read password1
    echo -e
    echo -e $echo_n ""$green"Re-enter password:"$nocol" $echo_c"
    read password2
    echo -e
    stty echo

    if [ "$password1" != "$password2" ]; then
        echo -e ""$red"Sorry, passwords do not match."$nocol""
        echo -e
        return 1
    fi

    if [ "$password1" = "" ]; then
        echo -e ""$cyan"Generating random password..."$nocol""
        password1=`randpw`
		echo -e ""$cyan"Randomly generated password is "$yellow"\""$password1"\""$nocol""
    fi

    esc_pass=`basic_single_escape "$password1"`
    do_query "UPDATE mysql.user SET Password=PASSWORD('$esc_pass') WHERE User='$remuser';"
    if [ $? -eq 0 ]; then
        echo -e ""$cyan"Password updated successfully!"$nocol""
        echo -e
    else
        echo -e ""$red"Password update failed!"$nocol""
    fi
}

reload_privilege_tables() {
    do_query "FLUSH PRIVILEGES;"
    if [ $? -eq 0 ]; then
	echo -e ""$cyan"Reload privileges tables success!"$nocol""
	return 0
    else
	echo -e ""$red"Reload privileges tables Failed!"$nocol""
	return 1
    fi
}

reload_hosts_tables() {
    do_query "FLUSH HOSTS;"
    if [ $? -eq 0 ]; then
	echo -e ""$cyan"Reload hosts tables success!"$nocol""
	return 0
    else
	echo -e ""$red"Reload hosts tables failed!"$nocol""
	return 1
    fi
}

randpw () { 
 < /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16}
echo
}

interrupt() {
    echo -e
    echo -e ""$red"Aborting!"$nocol""
    echo -e
    cleanup
    stty echo
    exit 1
}

cleanup() {
    echo -e ""$cyan"Cleaning up..."$nocol""
    rm -f $config $command
}

clean_and_exit() {
	cleanup
	exit 1
}

# The actual script starts here

#
# Mysql-server installation
#
echo -e
echo -e ""$cyan"NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MySQL"$nocol""
echo -e "    "$cyan"SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!"$nocol""
echo -e

echo -e $echo_n ""$green"Do you want to install or configure mysql-server? [Y/n]"$nocol" $echo_c"
read reply
echo -e
if [ "$reply" = "n" ]; then
	clean_and_exit
else
	mysql_install
fi

#
# Configuration part
#

prepare
find_mysql_client
set_echo_compat

echo -e
echo -e ""$cyan"In order to log into MySQL to secure it, we'll need the current"$nocol""
echo -e ""$cyan"password for the root user.  If you've just installed MySQL, and"$nocol""
echo -e ""$cyan"you haven't set the root password yet, the password will be blank,"$nocol""
echo -e ""$cyan"so you should just press enter here."$nocol""
echo -e

get_root_password

#
# Set the root password
#

echo -e ""$cyan"Setting the root password ensures that nobody can log into the MySQL"
echo -e "root user without the proper authorisation."$nocol""
echo -e

if [ $hadpass -eq 0 ]; then
    echo -e $echo_n ""$green"Set root password? [Y/n] "$nocol" $echo_c"
else
    echo -e ""$cyan"You already have a root password set, so you can safely answer 'n'"$nocol"."
    echo -e
    echo -e $echo_n ""$green"Change the root password? [Y/n]"$nocol" $echo_c"
fi

read reply
if [ "$reply" = "n" ]; then
    echo -e ""$cyan" ... skipping."$nocol""
else
    status=1
    while [ $status -eq 1 ]; do
	set_root_password
	status=$?
    done
fi
echo -e


#
# Remove anonymous users
#

echo -e ""$cyan"By default, a MySQL installation has an anonymous user, allowing anyone"
echo -e "to log into MySQL without having to have a user account created for"
echo -e "them.  This is intended only for testing, and to make the installation"
echo -e "go a bit smoother.  You should remove them before moving into a"
echo -e "production environment."$nocol""
echo -e

echo -e $echo_n ""$green"Remove anonymous users? [Y/n] "$nocol"$echo_c"

read reply
if [ "$reply" = "n" ]; then
    echo -e ""$cyan" ... skipping."$nocol""
else
    remove_anonymous_users
fi
echo -e


#
# Disallow remote root login
#

echo -e ""$cyan"Normally, root should only be allowed to connect from 'localhost'.  This"
echo -e "ensures that someone cannot guess at the root password from the network."$nocol""
echo -e

echo -e $echo_n ""$green"Disallow root login remotely? [Y/n]"$nocol"$echo_c"
read reply
if [ "$reply" = "n" ]; then
    echo -e " "$cyan"... skipping."$nocol""
else
    remove_remote_root
fi
echo -e


#
# Remove test database
#

echo -e ""$cyan"By default, MySQL comes with a database named 'test' that anyone can"
echo -e "access.  This is also intended only for testing, and should be removed"
echo -e "before moving into a production environment."$nocol""
echo -e

echo -e $echo_n ""$green"Remove test database and access to it? [Y/n] "$nocol" $echo_c"
read reply
if [ "$reply" = "n" ]; then
    echo -e ""$cyan" ... skipping."$nocol""
else
    remove_test_database
fi
echo -e

#
# Add remote user
#


echo -e $echo_n ""$green"Do you want to create user for remote access? [Y/n] "$nocol"$echo_c"
read reply
if [ "$reply" = "n" ]; then
    echo -e " "$cyan"... skipping."$nocol""
	exit 1
else
    add_remote_user
fi

#
#Set remote user password
#

if [ $? -ne 0 ]; then
     echo -e ""$red"Failed to create user for remote access!"$nocol""
	 clean_and_exit
	 else
	 set_remote_user_password
    fi



#
# Reload privilege and hosts tables
#

echo -e ""$cyan"Reloading the privilege tables will ensure that all changes made so far"
echo -e "will take effect immediately."$nocol""
echo -e

    reload_privilege_tables
	reload_hosts_tables

echo -e

cleanup

echo -e
echo -e
echo -e
echo -e ""$cyan"All done!  If you've completed all of the above steps, your MySQL"
echo -e "installation should now be secure."
echo -e
echo -e "Thanks for using MySQL!"$nocol""
echo -e

