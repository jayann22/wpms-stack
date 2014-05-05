#!/bin/bash
#This script is intended for automatic WordPress multisite installation 
#on Centos 6.5 x86_64 minimal installation machines 

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
TERM=linux
INSTALLDIR="/var/wpms-stack"
SOURCEREPO="https://github.com/Link7/wpms-stack.git"

if [[ -f /etc/profile.d/wpms.sh ]]
then
source /etc/profile.d/wpms.sh
fi

nocol="\033[0m"
red="\033[31m"
green="\033[032m"
cyan="\033[36m"

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#Function to install the proper git package
gitinstall () {
  if [[ ! `rpm -qa | grep rpmforge` ]]
  then

   echo -e ""$cyan"Installing and enabling rpmforge extras repository..."$nocol""
   rpm -i 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm'
    if [[ $? -ne 0 ]]
    then
     echo -e ""$red"echo failed to install rpmforge repos"$nocol""
     exit 1
    fi
   rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt 
   if [[ $? -ne 0 ]]
    then
     echo -e ""$red"echo failed to install rpmforge repos"$nocol""
     exit 1
    fi 

   sed -i '15,20s/enabled = 0/enabled = 1/' /etc/yum.repos.d/rpmforge.repo
    if [[ $? -ne 0 ]]
    then
     echo -e ""$red"echo failed to install rpmforge repos"$nocol""
     exit 1
    fi

  fi


  echo -e ""$cyan"Installing git...\n"$nocol""
  yum install -y git
  if [[ $? -ne 0 ]]
    then
     echo -e ""$red"echo failed to install git"$nocol""
     exit 1
  fi

}

#Function to clone git from source repository
gitclone () {

git clone $SOURCEREPO $INSTALLDIR

}

# Print help

if [[ $1 == -h ]] || [[  $1 == --help  ]] 
  then
   echo -e "$green Listing available options that could be passed to install.sh.\n
-c, --config:       Print existing configuration varables with their values
-h, --help:	    Print this Help
-g, --gitinstall:   Only Clone remote git repository and create bare repo with hook scripts$nocol"
exit 1
fi

if [[ $1 == -g ]] || [[  $1 == --gitinstall  ]]
 then
   echo -e ""$green" Cloning git repository from github and installing bare repository\n"
   gitinstall
exit 1
fi

#If install.sh runs with option --config , display the existing configurationg variables
if [[ $1 == "--config" ]] || [[ $1 == "-c" ]]
then

if [[ -f "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp ]]

echo -e ""$cyan"Your configuration file is "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp"$nocol""

then

   echo -e ""$green"\nPlease find below existing configuration variables and their values."$nocol"\n"
     j=0
     while read -e line
       do

echo -e ""$green"$line"$nocol""

     done < "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp


   exit 1
else
echo -e ""$red" You have not created configuration file yet"$nocol""
exit 1
fi
fi



randpw ()
{ 
  < /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16}
echo
}


#All stack and needed software instalation function
installeverything () {


	#Set symink which points to $WPMS-Environment-vars.pp . This link is included in file setup/puppet/modules/conf/init.pp as puppet configuration settings.
	mkdir /etc/wpms-stack
	ln -fs "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp  /etc/wpms-stack/envinit.pp


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
	  echo -e ""$red"Wget installation failed\nexiting..."$nocol""
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
	  echo -e ""$red"Puppet installation failed\nexiting..."$nocol""
	  exit 1
	fi

	#Start wpms installation, with puppet apply, check if failed,exit with message
	echo -e ""$cyan"Installing wpms-stack...\n"$nocol""
	 cd "$INSTALLDIR"/setup
	 puppet apply  --modulepath="$INSTALLDIR"/setup/puppet/modules "$INSTALLDIR"/setup/puppet/manifests/site.pp

	if [[ $? -ne 0 ]]
	 then
	  echo -e ""$red"Puppet installation failed\nexiting..."$nocol""
	fi
}

#Function for standard Installation Priocedure

standardinstall ()
{

#Check if mysql client is not installed, install it
if [[ ! -f /usr/bin/mysql ]]
then
echo -e ""$cyan" Installing mysql client""$nocol"
yum install -y mysql &> /dev/null
if [[ $? -ne 0 ]]
then
echo -e ""$red" Failed to install mysql client"$nocol""
fi

fi

#Check if WPMS_Environment is not set , then proceed to set 
#else ask if user wants to change or leave as it is
if [[ -z $WPMS_ENVIRONMENT ]] || [[ ! `cat /etc/profile.d/wpms.sh | grep "$WPMS_ENVIRONMENT"` ]]
then
   while :
   do
    echo -n -e "$green PLease provide a name for your environment: $nocol"
    read -e line

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
 echo -e -n "$green Enter a new name for your environment or press enter to leave it as"$nocol" $WPMS_ENVIRONMENT:"
   while :
   do
    read -e line
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
         echo -e -n "$green Please enter new name or press enter to leave it as $WPMS_ENVIRONMENT $nocol"
     fi

    done


fi


#Setting correct configuration file for WordPress installation
sample_file="$INSTALLDIR"/configs/sample-vars.pp
tmp_file=/tmp/env-vars`date +%N`.pp
file="$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp
i=0

#If configuration file already exists
if [[ -e "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp ]]
 then
echo -e ""$cyan"You already have a configuration file for the environment named "$WPMS_ENVIRONMENT"\n"
while :
do
echo -e -n ""$green"What will you choose?

1)Do not change anything
2)Proceed to new config file generation using the values from sample config file as defaults,
3)Proceed to new config file generation using the values from existing config file as defaults"$nocol": 1/2/3:"

read line

   case "$line" in
	 1)
 	  echo -e ""$cyan"You chose 1: Installing wpms-stack using options in existing "$WPMS_ENVIRONMENT"-vars.pp"$nocol"\n"
	  installeverything
          exit 1
	  ;;

	 2)
	  echo -e ""$cyan"You chose 2: Setting values in "$sample_file" as default and proceeding to new file generation..."$nocol"\n"
	  if [[ -f "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-wp-config.php ]]
	  then	
	   rm "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-wp-config.php
	  fi
	  break
	  ;;

	 3)
	  sample_file="$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-vars.pp
	  if [[ -f "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-wp-config.php ]]
	  then
	  rm "$INSTALLDIR"/configs/"$WPMS_ENVIRONMENT"-wp-config.php
	  fi
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
wrp_metod="$green Please provide method by which WordPress must be installed. The method can be GIT or WEB $nocol"
wp_get_address="$green Please provide URL from which the WordPress can be downloaded $nocol"
#wp_local_path="$green Please provide the full path of directory into which WordPress should be installed $nocol"
#wp_apache_local_path="$green Please provide the full path of public apache directory, which should be linked to WordPress install directory $nocol"
#wrp_owner="$green Please provide owner of WordPress install directory $nocol"
#wrp_group="$green Please provide group of WordPress install directory $nocol"
mysqlconfigure="$green Please answer Yes if the script shall create mysql database, mysql user for WordPress and grant accesses for the created user to WordPress database $nocol"
mysqldinstall="$green Please answer Yes if the script shall install mysql-server $nocol"
wrp_admin_user="$green Please provide username of administrator account for wpms-stack $nocol"
wrp_admin_password="$green Please provide password of administrator account for wpms-stack: $nocol"
wrp_dbname="$green Please provide database name for WordPress $nocol"
wrp_dbuser="$green Please provide database user for WordPress $nocol"
wrp_dbpass="$green Please provide password for WordPress database user:$nocol"
wrp_dbhost_access="$green Please provide the host from which will the user have access to database $nocol"
wrp_mysql_port="$green Please provide the mysql port to which WordPress shall connect $nocol"
wrp_mysqladm_user="$green Please provide the username which has privileges to grant accesses and create wp database on mysql server, e.g. root $nocol"
wrp_mysqladm_pass="$green Please provide the password for mysql admin user $nocol"
wrp_dbhost="$green Please provide the hostname or ip address of mysql to which WordPress shall connect $nocol"
#wrp_db_prefix="$green Please provide the database prefix, with which will be created tables $nocol"
#wrpcli="$green Please provide URL for WordPress CLI $nocol"
wrp_url="$green Please provide the main domain name of your WordPress Multisite installation $nocol"
wrp_title="$green Please provide title of your WordPress Multisite installation $nocol"
wrp_admin_email="$green Please provide email address of administrator account for WordPress $nocol"
wrp_plugin_MU="$green Please provide if WordPress MU Domain Mapping Plugin will be installed $nocol"
wrp_subdomain="$green Please enter "Yes" if WordPress Mutisite shall be installed in Subdomain mode or "No" for Subdirectory mode installation $nocol"
separator=""$green"################################################################## $nocol"




#Read Sample Configuration file and insert not commented non empty values into vars array
     while read -e line
       do

        if [[ ! $line =~ ^#.* ]] && [[ ! $line =~ "^\ +$" ]] && [[ ! -z $line ]]
         then
	  vars[$i]=`echo $line | tr -d ' '`
	  i=$((i+1))
        fi


     done < $sample_file


    #Read each element in array, cut/assign appropriate values, read -e new value on command line and change in cofig file if needed.
     for i in "${vars[@]}"
      do
	#Cut variable name from line in config file and assign to $var.
        var=`echo $i | cut -d "\$" -f2 | cut -d "=" -f1`
	#Cut present value ov variable and assign to $defaultvalue.
	defaultvalue=`echo $i | cut -d "\$" -f2 | cut -d "=" -f2`

if [[ -f $tmp_file ]]
then

db_admin=`cat $tmp_file | grep wrp_mysqladm_user | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
db_admin_pass=`cat $tmp_file | grep wrp_mysqladm_pass | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_db_user=`cat $tmp_file | grep wrp_dbuser | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_db_host=`cat $tmp_file | grep wrp_dbhost | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
wrp_db_port=`cat $tmp_file | grep wrp_mysql_port | cut -d "\$" -f2 | cut -d "=" -f2 | tr -d \"`
fi

if [[ ! -z $db_admin ]] && [[ -z $db_admin_pass ]]
then
 mysqlconnect="mysql -u "$db_admin" -h "$wrp_db_host" --port "$wrp_db_port""
else
 if [[ ! -z $db_admin ]] && [[ ! -z $db_admin_pass ]]
 then
  mysqlconnect="mysql -u "$db_admin" -h "$wrp_db_host" --port "$wrp_db_port" -p"$db_admin_pass""
 fi

fi

#Check and echo message if user must enter wrp_dbpass password
if [[ $var == "wrp_dbpass"  ]] && [[ -z `echo "$defaultvalue" | tr -d \"` ]]
 then
 echo -e ""$cyan"This is your first instllation using \""$WPMS_ENVIRONMENT"\" environment name: Enter password or leave it blank to use a randomly generated pasword."$nocol""
fi
if  [[ $var == "wrp_dbpass"  ]] && [[ ! -z `echo "$defaultvalue" | tr -d \"` ]]
then
 echo -e ""$cyan"You have already defined a password in your previous installation: Type new password, hit enter to leave it the same, or type G to generate random."$nocol""
fi

#Check and echo message if user must enter wrp_admin_password password
if [[ $var == "wrp_admin_password"  ]] && [[ -z `echo "$defaultvalue" | tr -d \"` ]]
 then
 echo -e ""$cyan"This is your first instllation using \""$WPMS_ENVIRONMENT"\" environment name: Enter password or leave it blank to use a randomly generated pasword."$nocol""
fi
if  [[ $var == "wrp_admin_password"  ]] && [[ ! -z `echo "$defaultvalue" | tr -d \"` ]]
then
 echo -e ""$cyan"You have already defined a password in your previous installation:  Type new password, hit enter to leave it the same, or type G to generate random."$nocol"
"
fi


	#Proceed if there exists comment for this variable on top of script
          if [[ ! -z  ${!var} ]] 
           then

	     #Check on step of entering password for mysql user and alert not to change password
	     #if there exists such user	
              if [[ $var == wrp_dbpass ]] && [[ `$mysqlconnect -e "select User from mysql.user;" | grep "$wrp_db_user" ` ]] &> /dev/null
               then
                echo -e "\n"$red"Warning: User with username "$wrp_db_user" already exists in mysql database, please define the correct password for that user or installation will be broken!!!"$nocol""
              fi


	     #Display the default value before reading user's input for new value on each iteration
             echo -e -n "${!var}. \n (The default Value is $defaultvalue): " 
             #Read new value on each iteration
             read -e newvalue


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
		          read -e newvalue
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
                          read -e newvalue
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
                          echo -e ""$red"Please answer Yes or No."$nocol""
			  echo -e -n "(The default Value is $defaultvalue): "
                          read -e newvalue
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
                          echo -e ""$red"Please answer Yes or No"$nocol""
			  echo -e -n "(The default Value is $defaultvalue): "
                          read -e newvalue
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
                          echo -e ""$red"Please answer Yes or No."$nocol""
			  echo -e -n "(The default Value is $defaultvalue): "
                          read -e newvalue
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
	               echo -e ""$red"Please answer Yes or No."$nocol""
	               echo -e -n "(The default Value is $defaultvalue): "
	               read -e newvalue
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
		     echo -e -n ""$cyan" Type new password, hit enter to leave it the same, or type G to generate random.- $defaultvalue: "$nocol""	
		     read -e newvalue
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
                     echo -e -n ""$cyan" Type new password, hit enter to leave it the same, or type G to generate random.- $defaultvalue: "$nocol""   
                     read -e newvalue
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

  read -e line

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

}
#End of standardinstall function


gitinstall
gitclone
standardinstall
installeverything

echo -e "\n\n"$cyan" You can push-pull from server repo through ssh \n server repo url is: ssh://root@SERVERIP:PORT"$INSTALLDIR".git"$nocol""
