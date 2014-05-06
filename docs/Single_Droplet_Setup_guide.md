This is step by step installation guide for wp multisite on single droplet Digital Ocean.
----------

Login to your Digital Ocean account and create 2 droplets, named e.g. wp-web and wp-db. In settings of each droplet mention following options.

*1)	Select Region: e.g. New York 2*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/region.png)


*2)	Select Image: Linux Distributions => CentOS => CentOS 6.5 x64*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/Image.png)

*3)	Settings: Select your SSH key by which you will connect to droplets and mention Private Networking option.*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/settings.png)

Now you can create droplets and after creation we will continue installation process by connecting to droplets via ssh client.
I assume that you have created droplet with hostname 
1) wpms  
and will continue guide using this name, but sure if you wish , you can set your hostname.


wp-multisite Installation
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
