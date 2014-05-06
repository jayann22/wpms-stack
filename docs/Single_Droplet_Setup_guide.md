This is step by step installation guide for wp multisite on single droplet Digital Ocean.
----------

Login to your Digital Ocean account and create 1 droplet, named e.g. wpms. In settings mention following options.

*1)	Select Region: e.g. New York 2*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/region.png)


*2)	Select Image: Linux Distributions => CentOS => CentOS 6.5 x64*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/Image.png)

*3)	Settings: Select your SSH key by which you will connect to droplets and mention Private Networking option.*

![](https://raw.githubusercontent.com/Link7/wpms-stack/master/docs/images/settings.png)

Now you can create droplets and after creation we will continue installation process by connecting to droplets via ssh client.

I assume that you have created droplet with hostname ***wpms*** and will continue guide using this name, but sure if you wish , you can set your hostname.


wp-multisite Installation
----------------------------------

Connect to wp-web droplet via ssh with root user, and execute following two commands.

    curl https://raw.githubusercontent.com/Link7/wpms-stack/master/setup/install.sh > install.sh

    bash install.sh

*1)	Choose Name for your Environment*

*2)	Proceed with setting values specific to your installation.*

I will not cover below all the values, which will ask install.sh, because the default values will work as well. 
install.sh will provide comments for each value, I strongly recommend to read comments before selecting default values and please keep the passwords which will be generated randomly during install.sh.

***Following are the values which must be changed during installation.***

>PLease provide a name for your environment: ***Name***

*(A name for you environment, such as production, or development, this name will be used to distinguish your various configuration files)*


> Please provide database user for wordpress.

>(The default Value is "wp_user"): ***some_username***

*(The db user for wordpress, please change this to one you prefer)*


>Please provide the main domain name of your WordPress Multisite installation . 

>(The default Value is "wpms-stack.local.link7.co"): ***your.domain.here***

*(The hostname of you worpdress multisite, this will not be real domain, but one by which you will connect to your wordpress)*



>Please provide email address of administrator account for WordPress .

>(The default Value is "admin@localhost.dev"): ***admin@your.domain.here***

*(The email address of wordpressadministrator )*



>Please provide username of administrator account for wpms-stack .

>(The default Value is "admin"): ***Admin username here***

*(This is the username of administrator of your wordpress installation, please change this to one you prefer)*


After you check/confirm the new settings, you will have installed wordpress multisite. 
After finish , the installation will print your worpdress domain name, the wordpress administrator username and random generated password for administrator user. 
