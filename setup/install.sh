#!/bin/bash
#This script is intended for automatic wordpress multisite installation on Centos 6.5 x86_64 minimal installation machines 

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [[ -f /etc/profile.d/wpms.sh ]]
then
source /etc/profile.d/wpms.sh
fi

nocol="\e\033[0m"
red="\e\033[31m"
green="\e\033[032m"
cyan="\e[36m"
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Print help

if [[ $1 == -h ]] || [[  $1 == --help  ]] 
  then
   echo -e "$green Listing available options that could be passed to install.sh.\n
-c, --config:    Print existing configuration varables with their values
-h, --help:	Print this Help $nocol"
   exit 1
fi


#All stack and needed software instalation function
installeverything () {


	#Set symink which points to $WPMS-Environment-vars.pp . This link is included in file setup/puppet/modules/conf/init.pp as puppet configuration settings.
	ln -fs `pwd`/../configs/"$WPMS_ENVIRONMENT"-vars.pp  /tmp/envinit.pp


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
	if [[ `rpm -Uv /tmp/epel-release-6*.rpm` ]] && [[ `rpm -Uvh /tmp/remi-release-6*.rpm` ]]
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

	 puppet apply  --modulepath=./puppet/modules ./puppet/manifests/site.pp

	if [[ $? -ne 0 ]]
	 then
	  echo -e "Puppet Installation failed\nexiting..."
	fi
}



if [[ -z $WPMS_ENVIRONMENT ]] || [[ ! `cat /etc/profile.d/wpms.sh | grep "$WPMS_ENVIRONMENT"` ]]
then
   while :
   do
    echo -n -e "$green PLease provide name for your environment: $nocol"
    read line

     if [[ $line =~ ^[a-zA-Z0-9]+$ ]]
       then
	break
       else
	echo -e "$red The environment name must not be empty and must contain only letters and digits $nocol" 
     fi

   done

echo "export WPMS_ENVIRONMENT=$line" >> /etc/profile.d/wpms.sh && source /etc/profile.d/wpms.sh

else
 echo -e "$green You have already set WPMS_ENVIRONMENT to $WPMS_ENVIRONMENT. $nocol" 
 echo -e -n "$green Enter new name for your environment or press enter to leave as"$nocol" $WPMS_ENVIRONMENT:"
   while :
   do
    read line
       if [[ -z $line ]]
        then 
	  echo -e "$green The environment name didn't change... $nocol\n"
	  break
       fi

     if [[ $line =~ ^[a-zA-Z0-9]+$ ]]
      then
	  sed -i 's/WPMS_ENVIRONMENT=.*/WPMS_ENVIRONMENT='$line'/'  /etc/profile.d/wpms.sh &&\
	  source /etc/profile.d/wpms.sh
          break
	 else
         echo -e "$red The environment name must not be empty and must contain only letters and digits $nocol"
         echo -e -n "$green please enter new name or press enter to leave as $WPMS_ENVIRONMENT $nocol"
     fi

    done


fi


#Setting correct configuration file for wordpress installation
sample_file=../configs/sample-vars.pp
tmp_file=/tmp/env-vars`date +%N`.pp
file=../configs/"$WPMS_ENVIRONMENT"-vars.pp
i=0

#If configuration file already exists
if [[ -e ../configs/"$WPMS_ENVIRONMENT"-vars.pp ]]
 then
echo -e ""$cyan"You already have configuration file for environment named "$WPMS_ENVIRONMENT"\n"
while :
do
echo -e -n ""$green"What will you choose?

1)Do not change anything
2)Proceed to new config file generation using as defaults the values from sample config file
3)Proceed to new config file generation using as defaults the values from existing config file"$nocol": 1/2/3:"

read line

   case "$line" in
	 1)
 	  echo -e ""$cyan"You chose 1: Installing wp-multisite-stack using options in existing "$WPMS_ENVIRONMENT"-vars.pp"$nocol"\n"
	  installeverything
          exit 1
	  ;;

	 2)
	  echo -e ""$cyan"You chose 2: Setting values in "$sample_file" as default and proceeding to new file generation..."$nocol"\n"
	  file="$WPMS_ENVIRONMENT"-vars.pp
	  break
	  ;;

	 3)
	  sample_file=../configs/"$WPMS_ENVIRONMENT"-vars.pp
	  echo -e ""$cyan"You chose 3: Setting values in "$sample_file" as default and proceeding to new file generation..."$nocol"\n"
	  break
	  ;;
	 *)
	 echo -e ""$red"\nPlease select value only from provided options"$nocol"\n"
   esac

done

fi


#The comments for each variable. If script determines variable with comment, it will ask user on command line.
current_mysqlroot_pass="$green Please provide root password of mysql $nocol"
wrp_metod="$green Please provide method by which worpdress must be installed.The method can be GIT or WEB $nocol"
wp_get_address="$green Please provide URL from which the wordpress can be downloaded $nocol"
wp_local_path="$green Please provide the full path of directory into which wordpress should be installed $nocol"
wp_apache_local_path="$green Please provide the full path of public apache directory, which should be linked to wordpress install directory $nocol"
#wrp_owner="$green Please provide owner of wordpress install directory $nocol"
#wrp_group="$green Please provide group of wordpress install directory $nocol"
mysqlconfigure="$green Please answer Yes if the script shall create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database $nocol"
mysqldinstall="$green Please answer Yes if the script shall install mysql-server $nocol"
wrp_dbname="$green Please provide database name for wordpress $nocol"
wrp_dbuser="$green Please provide database user for wordpress $nocol"
wrp_dbpass="$green Please provide password for wordpress database user $nocol"
wrp_dbhost_access="$green Please provide the host from which will the user have access to database $nocol"
wrp_dbhost="$green Please provide the hostname or ip address of mysql to which worpdress shall connect $nocol"
wrp_mysql_port="$green Please provide the mysql port to which worpdress shall connect $nocol"
wrp_mysqladm_user="$green Please provide the username which has privileges to grant accesses and create wp database on mysql server, e.g. root $nocol"
wrp_mysqladm_pass="$green Please provide the password for mysql admin user $nocol"
wrp_db_prefix="$green Please provide the database prefix, with which will be created tables $nocol"
#wrpcli="$green Please provide URL for Worpdress CLI $nocol"
wrp_url="$green Please provide the domain name of wp-multisite-stack $nocol"
wrp_title="$green Please provide title of wp-multisite-stack $nocol"
wrp_admin_email="$green Please provide email address of administrator account for wp-multisite-stack $nocol"
wrp_admin_user="$green Please provide username of administrator account for wp-multisite-stack $nocol"
wrp_admin_password="$green Please provide password of administrator account for wp-multisite-stack $nocol"
wrp_plugin_MU="$green Please provide if WordPress MU Domain Mapping Plugin will be installed $nocol"
wrp_subdomain="$green Please enter "Yes" if wordpress shall be installed with Subdomain mode or "No" for Subdirectory mode installation $nocol"
separator=""$green"################################################################## $nocol"


#If install.sh runs with option --config , display the existing confg variables
if [[ $1 == "--config" ]] || [[ $1 == "-c" ]]; then
   echo -e "$green Please find below existing configuration variables and their values. $nocol\n" 
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

		#Ensure that user entered valid data for wrp_subdomain variable
        	if [[ $var == "wrp_subdomain" ]]
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
	


		#Check if user entered new value , change the appropriate line in config file #else print message and leave as it is.
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
	echo -e -n "`cat $tmp_file`\n\n"$green"Please confirm settings that you have entered":$nocol" Y/N:"

  read line

	if [[ `echo $line | tr '[:upper:]' '[:lower:]'` == y ]]
		then
		cp -f $tmp_file $file
		rm $tmp_file 
		break
	fi

	  if [[ `echo $line | tr '[:upper:]' '[:lower:]'` == n ]] 
                then 
               echo -e ""$red"You didn't generate configuration file...\nPlease run install.sh to generate configuration file\nexiting..."$nocol""
	       rm $tmp_file
	       exit 1
	  fi

done


#After Config file successful configuration we can continue to puppet installation

installeverything

