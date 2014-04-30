#This is the sample configuration file for wpms-stack installation.
#The variables in this file are being used during installation process as defaults. 
#Please do not change or modify this file, instead use the wpms-stack/setup/install.sh script to generate a new config file for your environment.

#Specifies environment
$wrp_env = "dev"

#Specifies package name for apache installation, which is being provided to package manager such as yum. 
$apache = "httpd"

#Specifies package name for php installation, which is being provided to package manager such as yum.
$phpv = "php"

#Specifies package name for mysql server installation, which is being provided to package manager such as yum.
$mysqlpkg = "mysql-server"

#Specifies mysql service name to start or stop
$mysqld = "mysqld"

#Specifies mysql server root password
#$current_mysqlroot_pass =""

#Specifies the method by which will be downloaded WordPress files.
#This variable can be set to "WEB" or "GIT". 
#In case if is set to WEB as $wp_get_address must be provided the web URL from which the WordPress tarball should be download.
#In case if set to GIT, as $wp_get_address must be provided the git clone url.
#$wrp_metod="GIT"
#$wp_get_address ="git://core.git.wordpress.org/"

$wrp_metod="WEB"
$wp_get_address ="https://wordpress.org/latest.tar.gz"

#Specifies the full path of public apache directory, which should be linked to WordPress install directory"
$wp_apache_local_path="/var/www/wordpress"

#Apache conf file
$apache_conf_file="/etc/httpd/conf/httpd.conf"

#Specifies the directory into which WordPress should be installed.
$wp_local_path = "/var/wpms-stack/www/wordpress"

#apache parameters
$allowoverride="All"

#Specifies Owner of WordPress install directory
$wrp_owner = "apache"

#Specifies Group of WordPress install directory
$wrp_group = "apache"

#Specifies whether to create mysql database, mysql user for WordPress and grant accesses for the created user to WordPress database. 
$mysqlconfigure="Yes"

#Specifies whether to install mysql-server.
$mysqldinstall="Yes"

#Specifies the username which will have privileges to grant accesses and create wp database
$wrp_mysqladm_user = "root"

#Specifies the password for mysql admin user
$wrp_mysqladm_pass =""

#Specifies the hostname or ip address of mysql to which worpdress shall connect.
$wrp_dbhost = "localhost"

#Specifies the mysql port to which worpdress shall connect
$wrp_mysql_port ="3306"

#Specifies database name for WordPress
$wrp_dbname = "wordpress"

#Specifies mysql username for WordPress
$wrp_dbuser = "wp_user"

#Specifies mysql Password for WordPress
$wrp_dbpass = ""

#The host from which will be granted access for WordPress user to WordPress database
$wrp_dbhost_access = "localhost"

#Specifies the database prefix, with which will be created tables
$wrp_db_prefix = "wp_"

#Specifies the domain name of wpms-stack.
$wrp_url = "wpms-stack.local.link7.co"

#Specifies title of wpms-stack
$wrp_title = "WordPress"

#Specifies email address of administrator account for wpms-stack.
$wrp_admin_email = "admin@localhost.dev"

#Specifies username of administrator account for wpms-stack.
$wrp_admin_user = "admin"

#Specifies password of administrator account for wpms-stack.
$wrp_admin_password = ""

#Specifies if Multisite Plugin Manager will be installed.
$wrp_plugin_MU = "Yes"

#Specifies Multisite Subdomain installation mode in case of "Yes" or Subdirectory mode in case of No
$wrp_subdomain = "Yes"

#WordPress config path
$wrp_config_path = "/var/wpms-stack/configs"
