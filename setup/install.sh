#!/bin/bash
#This script is intended for automatic wordpress multisite installation 
#on Centos 6.5 x86_64 minimal installation machines 

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TERM=linux

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
randpw ()
{ 
  < /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16}
echo
}


#All stack and needed software instalation function
installeverything () {


	#Set symink which points to $WPMS-Environment-vars.pp . This link is included in file setup/puppet/modules/conf/init.pp as puppet configuration settings.
	ln -fs `pwd`/../configs/"$WPMS_ENVIRONMENT"-vars.pp  /tmp/envinit.pp


	#Install wget
	echo -e ""$cyan"Installing wget...\n"$nocol""

	if [[ ! `rpm -qa | grep wget` ]]
	then
	yum install -y wget
	else
	echo -e ""$cyan"Wget is already installed"$nocol""
	fi

	if [[ $? -ne 0 ]]
	 then
	  echo -e ""$red"Wget Installation failed\nexiting..."$nocol""
	  exit 1
	fi

	#Install epel repository for Centos 6.5, this is needed for puppet installation

	echo -e ""$cyan"Downloading EPEL repository packages...\n"$nocol""
	wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /tmp/epel-release-6-8.noarch.rpm &&\
	wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm -O /tmp/remi-release-6.rpm

	if [[ $? -ne 0 ]]
	 then
	  echo -e ""$red"Getting Epel repository packages failed\nexiting..."$nocol""
	  exit 1
	fi

	#Install EPEL repos and exit script if failed

	echo -e ""$cyan"Installing EPEL repository packages...\n"$nocol""
	if [[ `rpm -Uv /tmp/epel-release-6*.rpm` ]] && [[ `rpm -Uvh /tmp/remi-release-6*.rpm` ]]
	 then 
	  rm -rf /tmp/remi-release-6*.rpm /tmp/epel-release-6*.rpm
	 else
	  rm -rf /tmp/remi-release-6*.rpm /tmp/epel-release-6*.rpm
	  echo -e ""$red"Installation of EPEL repository packages failed\nexiting..."$nocol""
	  exit 1
	fi

	#Install puppet if it is not installed, exit if installation failed
	echo -e ""$cyan"Installing puppet...\n"$nocol""
	
	if [[ ! `rpm -qa | grep puppet` ]]
	then
	 yum install -y puppet
	else
	 echo -e ""$cyan"Puppet is already installed"$nocol""
	fi

	if [[ $? -ne 0 ]]
	 then
	  echo -e ""$red"Puppet Installation failed\nexiting..."$nocol""
	  exit 1
	fi

	#Start wp-multisite installation, with puppet apply, check if failed,exit with message
	echo -e ""$cyan"Installing WP-Multisite-Stack...\n"$nocol""

	 puppet apply  --modulepath=./puppet/modules ./puppet/manifests/site.pp

	if [[ $? -ne 0 ]]
	 then
	  echo -e ""$red"Puppet Installation failed\nexiting..."$nocol""
	fi
}


#Check if WPMS_Environment is not set , then proceed to set 
#else ask if user wants to change or leave as it is
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
2)Proceed to new config file generation using as defaults the values from sample config file,
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
	  rm ../configs/"$WPMS_ENVIRONMENT"-wp-config.php
	  break
	  ;;

	 3)
	  sample_file=../configs/"$WPMS_ENVIRONMENT"-vars.pp
	  rm ../configs/"$WPMS_ENVIRONMENT"-wp-config.php
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
#wp_local_path="$green Please provide the full path of directory into which wordpress should be installed $nocol"
#wp_apache_local_path="$green Please provide the full path of public apache directory, which should be linked to wordpress install directory $nocol"
#wrp_owner="$green Please provide owner of wordpress install directory $nocol"
#wrp_group="$green Please provide group of wordpress install directory $nocol"
mysqlconfigure="$green Please answer Yes if the script shall create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database $nocol"
mysqldinstall="$green Please answer Yes if the script shall install mysql-server $nocol"
wrp_admin_user="$green Please provide username of administrator account for wp-multisite-stack $nocol"
wrp_admin_password="$green Please provide password of administrator account for wp-multisite-stack: Enter G to generate random password or leave blank to leave the default value $nocol"
wrp_dbname="$green Please provide database name for wordpress $nocol"
wrp_dbuser="$green Please provide database user for wordpress $nocol"
wrp_dbpass="$green Please provide password for wordpress database user: Enter G to generate random password or leave blank to leave the default value$nocol"
#wrp_dbhost_access="$green Please provide the host from which will the user have access to database $nocol"
wrp_mysql_port="$green Please provide the mysql port to which worpdress shall connect $nocol"
#wrp_mysqladm_user="$green Please provide the username which has privileges to grant accesses and create wp database on mysql server, e.g. root $nocol"
#wrp_mysqladm_pass="$green Please provide the password for mysql admin user $nocol"
#wrp_dbhost="$green Please provide the hostname or ip address of mysql to which worpdress shall connect $nocol"
#wrp_db_prefix="$green Please provide the database prefix, with which will be created tables $nocol"
#wrpcli="$green Please provide URL for Worpdress CLI $nocol"
wrp_url="$green Please provide the domain name of wp-multisite-stack $nocol"
wrp_title="$green Please provide title of wp-multisite-stack $nocol"
wrp_admin_email="$green Please provide email address of administrator account for wp-multisite-stack $nocol"
wrp_plugin_MU="$green Please provide if WordPress MU Domain Mapping Plugin will be installed $nocol"
wrp_subdomain="$green Please enter "Yes" if wordpress shall be installed with Subdomain mode or "No" for Subdirectory mode installation $nocol"
separator=""$green"################################################################## $nocol"


#If install.sh runs with option --config , display the existing configurationg variables
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

if [[ -f $tmp_file ]]
then

wrp_mysqladm_user=`cat $tmp_file | grep wrp_mysqladm_user | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_mysqladm_pass=`cat $tmp_file | grep wrp_mysqladm_pass | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_dbuser=`cat $tmp_file | grep wrp_dbuser | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_dbhost=`cat $tmp_file | grep wrp_dbhost | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
fi

if [[ ! -z $wrp_mysqladm_user ]] && [[ -z $wrp_mysqladm_pass ]]
then
 mysqlconnect="mysql -u "$wrp_mysqladm_user" -h "$wrp_dbhost""
else
 if [[ ! -z $wrp_mysqladm_user ]] && [[ ! -z $wrp_mysqladm_pass ]]
 then
  mysqlconnect="mysql -u "$wrp_mysqladm_user" -h "$wrp_dbhost" -p"$wrp_mysqladm_pass""
 fi

fi
	#Proceed if there exists comment for this variable on top of script
          if [[ ! -z  ${!var} ]] 
           then

	     #Check on step of entering password for mysql user and alert not to change password
	     #if there exists such user	

              if [[ -f "/etc/init.d/mysqld" ]] && [[ $var == wrp_dbpass ]] && [[ `$mysqlconnect -e "select User from mysql.user;" | grep "$wrp_dbuser"` ]]
               then
                echo -e "\n"$red"There is already user with username "$wrp_dbuser" in mysql database that ou have provided, please define the correct password for that user or installation will be broken!!!"$nocol""
              fi

	     #Display the default value before reading user's input for new value on each iteration
             echo -e -n "${!var}. \n (The default Value is $defaultvalue): " 
             #Read new value on each iteration
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
		          echo -e ""$red"The value can be GIT or WEB."$nocol""
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
                          echo -e ""$red"Please provide valid URL."$nocol""
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
                          echo -e ""$red"Please answere Yes or No."$nocol""
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
                          echo -e ""$red"Please answere Yes or No"$nocol""
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
                          echo -e ""$red"Please answere Yes or No."$nocol""
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
	               echo -e ""$red"Please answere Yes or No."$nocol""
	               echo -e -n "(The default Value is $defaultvalue): "
	               read newvalue
		    fi
		   done
	         fi


		if [[ $var == "wrp_dbpass" ]]
                 then
                  while :
                   do

		      if [[ `echo "$newvalue" | tr '[:upper:]' '[:lower:]'` == g ]]
		       then
			   echo -e ""$cyan"Generating random password"$nocol""  
			   newvalue=`randpw`
			   break
		       fi
			if [[ -z `echo "$defaultvalue" | tr -d \"` ]] && [[ -z $newvalue ]]
			  then
			echo -e ""$cyan" Your default password is blank, generating random password... "$nocol""
			  newvalue=`randpw`
			  break
			fi

                 	if [[ -z "$newvalue" ]] && [[ ! -z `echo "$defaultvalue" | tr -d \"` ]]
			 then
			  break
			 fi
			if [[ ! -z "$newvalue" ]] && [[ "${#newvalue}" -ge 8 ]] && [[ ! `echo "$newvalue"` =~ .+\ +  ]]
			 then
			  break
			fi
		     echo -e ""$red"Your password must have at least 8 characters and must not contain spaces"$nocol""
		     echo -e -n ""$cyan" Please enter password or hit Enter to leave the default parameter or G to generate random password- $defaultvalue: "$nocol""	
		     read newvalue
                   done
                 fi

		if [[ $var == "wrp_admin_password" ]]
                 then
                  while :
                   do

                      if [[ `echo "$newvalue" | tr '[:upper:]' '[:lower:]'` == g ]]
                       then
                           echo -e ""$cyan"Generating random password"$nocol""  
                           newvalue=`randpw`
                           break
                       fi
                        if [[ -z `echo "$defaultvalue" | tr -d \"` ]] && [[ -z $newvalue ]]
                          then
                        echo -e ""$cyan" Your default password is blank, generating random password... "$nocol""
                          newvalue=`randpw`
                          break
                        fi

                        if [[ -z "$newvalue" ]] && [[ ! -z `echo "$defaultvalue" | tr -d \"` ]]
                         then
                          break
                         fi
                        if [[ ! -z "$newvalue" ]] && [[ "${#newvalue}" -ge 8 ]] && [[ ! `echo "$newvalue"` =~ .+\ +  ]]
                         then
                          break
                        fi
                     echo -e ""$red"Your password must have at least 8 characters and must not contain spaces"$nocol""
                     echo -e -n ""$cyan" Please enter password or hit Enter to leave the default parameter or G to generate random password- $defaultvalue: "$nocol""   
                     read newvalue
                   done
                 fi


		#Check if user entered new value , change the appropriate line in config file #else print message and leave as it is.
                if [[ -z $newvalue ]]
                 then
		  echo -e "$i" >> $tmp_file

		  echo -e ""$cyan"Leaving as default..."$nocol""
		  echo -e "$var=$defaultvalue\n$separator\n"
		 else
		  echo -e ""$cyan"changing defaultvalue $defaultvalue of $var to \"$newvalue\" in $file\n\n$separator\n"$nocol""
                  echo "\$$var=\"$newvalue\"" >> $tmp_file
	        fi
	     else
	   echo "$i" >> $tmp_file 

           fi

       done
#Set Environment name in temporary config file before displaying to user for final decision
sed -i 's,$wrp_env="dev",$wrp_env="'$WPMS_ENVIRONMENT'",' $tmp_file

#Cat temporary config file created by user's answers and ask if user agrees with it proceed, else terminate script
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

