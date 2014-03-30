#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Print help

if [[ $1 == -h ]] || [[  $1 == --help  ]] 
  then
   echo -e "Listing available options that could be passed to install.sh.\n 
-c, --config:    Print existing configuration varables with their values
-h, --help:	Print this Help"
   exit 1
fi

#copies samle vars.pp file to env-vars.pp so it doesn't overwrite the sample.
#cp ../configs/sample-vars.pp ../configs/env-vars.pp

#This script is intended for automatic wordpress multisite installation on Centos 6.5 x86_64 minimal installation machines 
sample_file=../configs/sample-vars.pp
tmp_file=/tmp/env-vars`date +%N`.pp
file=../configs/env-vars.pp
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
i=0
separator="------------------------------------------------------"


#The comments for each variable. If script determines variable with comment, it will ask user on command line.

#apache="Apache Comment"
#phpv="php Comment"
#mysqlpkg="mysqlpkg Comment"
#mysqld="mysqld Comment"
current_mysqlroot_pass="Please provide root password of mysql"
wrp_metod="Please provide method by which worpdress must be installed.The method can be GIT or WEB"
wp_get_address="Please provide URL from which the wordpress can be downloaded"
wp_local_path="Please provide the full path of directory into which wordpress should be installed"
wp_apache_local_path="Please provide the full path of public apache directory, which should be linked to wordpress install directory"
wrp_owner="Please provide owner of wordpress install directory"
wrp_group="Please provide group of wordpress install directory"
mysqlconfigure="Please answer Yes if the script shall create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database"
mysqldinstall="Please answer Yes if the script shall install mysql-server"
wrp_dbname="Please provide database name for wordpress"
wrp_dbuser="Please provide database user for wordpress"
wrp_dbpass="Please provide password for wordpress database user"
wrp_dbhost_access="Please provide the host from which will the user have access to database"
wrp_dbhost="Please provide the hostname or ip address of mysql to which worpdress shall connect"
wrp_mysql_port="Please provide the mysql port to which worpdress shall connect"
wrp_mysqladm_user="Please provide the username which has privileges to grant accesses and create wp database on mysql server, e.g. root"
wrp_mysqladm_pass="Please provide the password for mysql admin user"
wrp_db_prefix="Please provide the database prefix, with which will be created tables"
wrpcli="Please provide URL for Worpdress CLI"
wrp_url="Please provide the domain name of wp-multisite-stack"
wrp_title="Please provide title of wp-multisite-stack"
wrp_admin_email="Please provide email address of administrator account for wp-multisite-stack"
wrp_admin_user="Please provide username of administrator account for wp-multisite-stack"
wrp_admin_password="Please provide password of administrator account for wp-multisite-stack"
wrp_plugin_MU="Please provide if WordPress MU Domain Mapping Plugin will be installed"


#If install.sh runs with option --config , display the existing confg variables
if [[ $1 == "--config" ]] || [[ $1 == "-c" ]]; then
   echo -e "Please find below existing configuration variables and their values.\n" 
     j=0
     while read line
       do

        if [[ ! $line =~ ^#.* ]] && [[ ! $line =~ "^\ +$" ]] && [[ ! -z $line ]]
         then
          info[$j]=`echo $line | tr -d ' '`
          j=$((j+1))
        fi


     done < $file


 #Print new values from confg file to display that user could save them.
 for k in "${info[@]}"
  do
        var=`echo $k | cut -d "\$" -f2 | cut -d "=" -f1`

        #Cut present value ov variable and assign to $defaultvalue.
        value=`echo $k | cut -d "\$" -f2 | cut -d "=" -f2`

      if [[ ! -z  ${!var} ]]
        then
         echo -e " $var = $value "
      fi
 
   done



   exit 1
fi



#Read Sample Configuration file and insert not commented non empty values into vars array
     while read line
       do

        if [[ ! $line =~ ^#.* ]] && [[ ! $line =~ "^\ +$" ]] && [[ ! -z $line ]]
         then
	  vars[$i]=`echo $line | tr -d ' '`
	  i=$((i+1))
        fi


     done < $sample_file


    #Read each element in array, cut/assign appropriate values, read new value on command line and change in cofig file if needed.
     for i in "${vars[@]}"
      do
	#Cut variable name from line in config file and assign to $var.
        var=`echo $i | cut -d "\$" -f2 | cut -d "=" -f1`

	#Cut present value ov variable and assign to $defaultvalue.
	defaultvalue=`echo $i | cut -d "\$" -f2 | cut -d "=" -f2`



	#Proceed if there exists comment for this variable on top of script
          if [[ ! -z  ${!var} ]] 
           then
            echo -e -n "${!var}. \n (The default Value is $defaultvalue): "

	    read newvalue

		  #Ensure that user entered valid data for wrp_metod variable
	       	  if [[ $var == "wrp_metod" ]]
		   then
		     while :
		      do
			if [[ $newvalue == "GIT" ]] || [[ $newvalue == "WEB" ]] || [[ -z $newvalue ]]
			 then
			  break
			 else
		          echo "The value can be GIT or WEB."
			  echo -e -n "(The default Value is $defaultvalue): "
		          read newvalue
			fi
		      done
		  fi

		  #Ensure that user entered valid data for wp_get_address variable
		  if [[ $var == "wp_get_address" ]]
                   then
                     while :
                      do
                        if [[ $newvalue =~ ^http://.+ ]] || [[ $newvalue =~ ^https://.+ ]] || [[ $newvalue =~ ^git://.+ ]] || [[ -z $newvalue ]]
                         then
                          break
                         else
                          echo "Please provide valid URL."
			  echo -e -n "(The default Value is $defaultvalue): "
                          read newvalue
                        fi
                      done
                  fi
		  #Ensure that user entered valid data for mysqlconfigure variable
		  if [[ $var == "mysqlconfigure" ]]
                   then
                     while :
                      do
                        if [[ $newvalue == "Yes" ]] || [[ $newvalue == "No" ]] || [[ -z $newvalue ]]
                         then
                          break
                         else
                          echo "Please answere Yes or No."
			  echo -e -n "(The default Value is $defaultvalue): "
                          read newvalue
                        fi
                      done
                  fi
		 #Ensure that user entered valid data for mysqldinstall variable
		  if [[ $var == "mysqldinstall" ]]
                   then
                     while :
                      do
                        if [[ $newvalue == "Yes" ]] || [[ $newvalue == "No" ]] || [[ -z $newvalue ]]
                         then
                          break
                         else
                          echo "Please answere Yes or No"
			  echo -e -n "(The default Value is $defaultvalue): "
                          read newvalue
                        fi
                      done
                  fi

                 #Ensure that user entered valid data for wrp_plugin_MU variable
                  if [[ $var == "wrp_plugin_MU" ]]
                   then
                     while :
                      do
                        if [[ $newvalue == "Yes" ]] || [[ $newvalue == "No" ]] || [[ -z $newvalue ]]
                         then
                          break
                         else
                          echo "Please answere Yes or No."
			  echo -e -n "(The default Value is $defaultvalue): "
                          read newvalue
                        fi
                      done
                  fi

		#Check if user entered new value , change the appropriate line in config file, 
		#else print message and leave as it is.
                if [[ -z $newvalue ]]
                 then
		  echo -e "$i" >> $tmp_file

		  echo "Leaving as default..."
		  echo -e "$var=$defaultvalue\n$separator\n"
		 else
		  echo -e "changing defaultvalue $defaultvalue of $var to \"$newvalue\" in $file\n\n$separator\n"
                  echo "\$$var=\"$newvalue\"" >> $tmp_file
	        fi
	     else
	   echo "$i" >> $tmp_file 

           fi

       done



while :
do
	echo -e -n "`cat $tmp_file`\n\nPlease confirm settings that you have entered: Y/N:"

  read line

	if [[ `echo $line | tr '[:upper:]' '[:lower:]'` == y ]]
		then
		cp -f $tmp_file $file
		rm $tmp_file 
		break
	fi

	  if [[ `echo $line | tr '[:upper:]' '[:lower:]'` == n ]] 
                then 
               echo -e "You didn't generate configuration file...\nPlease run install.sh to generate configuration file\nexiting..."
	       rm $tmp_file
	       exit 1
	  fi

done




#After Config file successful configuration we can continue to puppet installation

#Install wget
echo -e "Installing wget...\n"

if [[ ! `rpm -qa | grep wget` ]]
then
yum install -y wget
else
echo "Wget is already installed"
fi

if [[ $? -ne 0 ]]
 then
  echo "Wget Installation failed\nexiting..."
  exit 1
fi

#Install epel repository for Centos 6.5, this is needed for puppet installation

echo -e "Downloading EPEL repository packages...\n"
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /tmp/epel-release-6-8.noarch.rpm &&\
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm -O /tmp/remi-release-6.rpm

if [[ $? -ne 0 ]]
 then
  echo -e "Getting Epel repository packages failed\nexiting..."
  exit 1
fi

#Install EPEL repos and exit script if failed

echo -e "Installing EPEL repository packages...\n"
if [[ `rpm -Uvh /tmp/remi-release-6*.rpm` ]] && [[ `rpm -Uv /tmp/epel-release-6*.rpm` ]]
 then 
  rm -rf /tmp/remi-release-6*.rpm /tmp/epel-release-6*.rpm
 else
  rm -rf /tmp/remi-release-6*.rpm /tmp/epel-release-6*.rpm
  echo -e "Installation of EPEL repository packages failed\nexiting..."
  exit 1
fi

#Install puppet if it is not installed, exit if installation failed
echo -e "Installing puppet...\n"

if [[ ! `rpm -qa | grep puppet` ]]
then
 yum install -y puppet
else
 echo "puppet is already installed"
fi

if [[ $? -ne 0 ]]
 then
  echo -e "Puppet Installation failed\nexiting..."
  exit 1
fi

#Start wp-multisite installation, with puppet apply, check if failed,exit with message
echo -e "Installing WP-Multisite-Stack...\n"

 puppet apply puppet/manifests/site.pp

if [[ $? -ne 0 ]]
 then
  echo -e "Puppet Installation failed\nexiting..."
  else
  echo "WP-Multisite-Stack is installed Successful"
fi
