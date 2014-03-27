#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#This script is intended for automatic wordpress multisite installation on Centos 6.5 x86_64 minimal installation machines 

file=classes/vars.pp
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
wrp_owner="Please provide owner of wordpress install directory"
wrp_group="Please provide group of wordpress install directory"
mysqlconfigure="Please answer yes if the script shall create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database"
mysqldinstall="Please answer yes if the script shall install mysql-server"
wrp_dbname="Please provide database name for wordpress"
wrp_dbuser="Please provide database user for wordpress"
wrp_dbpass="Please provide password for wordpress database user"
wrp_dbhost_access="Please provide the host from which will the user have access to database"

#Read Configuration file and insert not commented non empty values into vars array
     while read line
       do

        if [[ ! $line =~ ^#.* ]] && [[ ! $line =~ "^\ +$" ]] && [[ ! -z $line ]]
         then
	  vars[$i]=`echo $line | tr -d ' '`
	  i=$((i+1))
        fi


     done < $file


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
            echo -e -n "${!var} - (The default Value is $defaultvalue): "

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
		          echo "The value you have provided is wrong for this configuration parameter"
		          read newvalue
			fi
		      done
		  fi

		  #Ensure that user entered valid data for wp_get_address variable
		  if [[ $var == "wp_get_address" ]]
                   then
                     while :
                      do
                        if [[ $newvalue =~ ^http://.+ ]] || [[ $newvalue =~ ^git://.+ ]] || [[ -z $newvalue ]]
                         then
                          break
                         else
                          echo "Please provide valid URL"
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
                          echo "Please answere Yes or No"
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
                          read newvalue
                        fi
                      done
                  fi


		#Check if user entered new value , change the appropriate line in config file, 
		#else print message and leave as it is.
                if [[ -z $newvalue ]]
                 then
		  echo "Leaving as default..."
		  echo -e "$var=$defaultvalue"
		  echo -e "$separator\n"
		 else
		  echo -e "changing defaultvalue \"$defaultvalue\" of $var to \"$newvalue\" in $file"
		  echo -e "$separator\n"
		  sed -i "s,$var.*,$var=$newvalue," $file
	        fi

           fi

       done

#After Config file successful configuration we can continue tu puppet installation

#Install wget
#yum install -y wget

#Install epel repository for Centos 6.5, this is needed for puppet installation
#wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
#rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm

#Install puppet
#yum install -y puppet
