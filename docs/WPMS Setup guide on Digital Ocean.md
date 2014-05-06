This is step by step installation guide for wp multisite on Digital Ocean, with separate web and database droplets which are connected to each other via private network.
----------

Login to your Digital Ocean account and create 2 droplets, named e.g. wp-web and wp-db. In settings of each droplet mention following options.

*1)	Select Region: New York 2*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/region.png)


*2)	Select Image: Linux Distributions => CentOS => CentOS 6.5 x64*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/Image.png)

*3)	Settings: Select your SSH key by which you will connect to droplets and mention Private Networking option.*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/settings.png)

Now you can create droplets and after creation we will continue installation process by connecting to droplets via ssh client.
I assume that you have created droplets with hostnames 
1) wp-web  
2) wp-db 
and will continue guide using these names, but sure if you wish , you can set your hostnames.

Choose your droplets on Digital Ocean interface and determine their private ip addresses.
Write these ip addresses somewhere, because we will use them during installation.

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/privateip.png)


 I will use 10.128.1.1 and 10.128.2.2 respectively for wp-web and wp-db.

1) wp-web:  10.128.1.1

2) wp-db:  10.128.2.2

I will divide installation procedure into 2 main phases: 
1.	Database installation
2.	 web installation


Phase 1. Database Installation
------------------------------

Connect to wp-db droplet via ssh , and install mysql-server 

You can install it automatically, using script or manually.

***Automatic installation of mysql server with script***

Login to your system as root or sudoer user and execute following commands

     curl -I https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/scripts/mysql-server-install.sh > mysql-server-install.sh
     sudo bash mysql-server-install.sh
     
1)	Choose mysql user with root privileges, I chose ***Admin***

2)	Choose password for Admin user, which must be specified during wordpress multisite stack installation: I chose ***ROOTPASSWORD***

3)	Choose private network range of Digital Ocean in NY2: ***10.128.%.%*** 


***Manual Installation of mysql server***

     yum -y install mysql-server

After successful installation, start the service and set the service to automatically start during boot.

    service mysqld start
    chkconfig --level 3 mysqld on

Now you can connect to mysql and set appropriate accounts by which wordpress installation script and web service will connect to database.Please note that Values in Red must be changed.

    mysql -e "create user 'ADMIN'@'10.128.%.%' identified by 'ROOTPASSWORD'"  
    mysql -e "grant all privileges on *.* to  'ADMIN'@'10.128.%.%'with grant option" 
    mysql -e "flush privileges" 
    mysql -e "flush hosts"

where

1)	***ADMIN*** is mysql user with root privileges

2)	***ROOTPASSWORD*** is password for admin user, which must be specified during wordpress multisite stack  installation

3)	***10.128.%.%*** is private network of Digital Ocean in NY2.

Phase 2. wp-multisite Installation
----------------------------------

Connect to wp-web droplet via ssh with root user, and execute following two commands.

    curl https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/install.sh > install.sh

    bash install.sh

*1)	Choose Name for your Environment*

*2)	Proceed with setting values specific to your installation.*

Following are the values which must be set during installation. The values in ***Bold-Italic*** must be changed during installation, in case if wpms must be installed with separate database server. I will not cover below  the other values, which will ask install.sh because they are environment specific. 

> Please answer Yes if the script shall create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database.

>(The default Value is "Yes"):***Yes***

*(Set this to Yes , because we need to create wp user)*

> Please answer Yes if the script shall install mysql-server.

>(The default Value is "Yes"):***No***

 *(Set this to NO, because we already have installed mysql)*
 
> Please provide the username which has privileges to grant accesses and create wp database on mysql server, e.g. root

>(The default Value is "root"):***ADMIN***

*(The mysql super user, which we created on wp-db server)*

> Please provide the password for mysql admin user.

>(The default Value is> ""):***ROOTPASSWORD***

*(The password for mysql super-user on wp-db server)*

> Please provide the hostname or ip address of mysql to which worpdress shall connect. 

>(The default Value is "localhost"):***10.128.2.2***

 *(The private ip address for wp-db server)*

> Please provide database user for wordpress.

>(The default Value is "wp_user"): 

*(The db user for wordpress, this can be leaved as default)*

> Please provide the host from which the user will have access to database.  

>(The default Value is "localhost"):***10.128.%.%***

*( Private network, from which db user for wordpress will have access to mysql db)*

After you check/confirm the new settings, you will have installed wordpress multisite. 
