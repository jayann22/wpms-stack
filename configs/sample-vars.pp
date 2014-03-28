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

#Specifies the method by which will be downloaded wordpress files.
#This variable can be set to "WEB" or "GIT". 
#In case if is set to WEB as $wp_get_address must be provided the web URL from which the wordpress tarball should be download.
#In case if set to GIT, as $wp_get_address must be provided the git clone url.
#$wrp_metod="GIT"
#$wp_get_address ="git://core.git.wordpress.org/"

$wrp_metod="WEB"
$wp_get_address ="https://wordpress.org/latest.tar.gz"

#Specifies the directory into which wordpress should be installed.
$wp_local_path = "/var/www/html/"

#Specifies Owner of wordpress install directory
$wrp_owner = "apache"

#Specifies Group of wordpress install directory
$wrp_group = "apache"

#Specifies whether to create mysql database, mysql user for wordpress and grant accesses for the created user to wordpress database. 
$mysqlconfigure="Yes"

#Specifies whether to install mysql-server.
$mysqldinstall="Yes"

#Specifies database name for wordpress
$wrp_dbname = "wordpress"

#Specifies mysql username for wordpress
$wrp_dbuser = "wp_user"

#Specifies mysql Password for wordpress
$wrp_dbpass = "secretwppass"

#The host from which will be granted access for wordpress user to wordpress database
$wrp_dbhost_access = "localhost"

#Specifies the hostname or ip address of mysql to which worpdress shall connect.
$wrp_dbhost = "localhost"

#Specifies the mysql port to which worpdress shall connect
$wrp_mysql_port ="3306"

#Specifies the username which will have privileges to grant accesses and create wp database
$wrp_mysqladm_user = "root"

#Specifies the password for mysql admin user
$wrp_mysqladm_pass =""

#Specifies the database prefix, with which will be created tables
$wrp_db_prefix = "wp_"

#Specifies URL for Worpdress CLI
$wrpcli = "https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"

#Specifies the domain name of wp-multisite-stack.
$wrp_url = "wp-multisite-stack.link7.co"

#Specifies title of wp-multisite-stack
$wrp_title = "WP Multisite"

#Specifies email address of administrator account for wp-multisite-stack.
$wrp_admin_email = "admin@localhost"

#Specifies username of administrator account for wp-multisite-stack.
$wrp_admin_user = "admin"

#Specifies password of administrator account for wp-multisite-stack.
$wrp_admin_password = "admin"

#Specifies if Multisite Plugin Manager will be installed.
$wrp_plugin_MU = "Yes"

