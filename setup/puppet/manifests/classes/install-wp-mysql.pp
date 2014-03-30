define install_wp_mysql( $wp_dbname, $wp_dbuser, $wp_dbpass, $wp_dbhost_access, $mysqlconf, $mysqlinstall, 
			    $wp_dbhost, $wp_mysqladm_user, $wp_mysqladm_pass, $wp_mysql_port){
  
    if $mysqlconf == 'Yes' { 
	if $mysqlinstall == 'Yes' {
	    include mysql
	
	exec{"WP_DB_Add":
		command => "/usr/bin/mysql -h $wp_dbhost -P $wp_mysql_port -u $wp_mysqladm_user -p$wp_mysqladm_pass -e \"CREATE DATABASE IF NOT EXISTS $wp_dbname;\"",
#		require => Class["mysql"],
	    }
	}
	else {
		exec{"WP_DB_Add":
			command => "/usr/bin/mysql -h $wp_dbhost -P $wp_mysql_port -u $wp_mysqladm_user -p$wp_mysqladm_pass -e \"CREATE DATABASE IF NOT EXISTS $wp_dbname;\"",
		    }
	    }

    exec{"WP_DB_Configuration":
	    command => "/usr/bin/mysql -h $wp_dbhost -P $wp_mysql_port -u $wp_mysqladm_user -p$wp_mysqladm_pass -e \"GRANT ALL PRIVILEGES ON $wp_dbname.* TO '$wp_dbuser'@'$wp_dbhost_access';\"",
	    require => Exec["WP_DB_Add"],
	    onlyif => "/usr/bin/mysql -h $wp_dbhost -P $wp_mysql_port -u $wp_mysqladm_user -p$wp_mysqladm_pass -e \"CREATE USER '$wp_dbuser'@'$wp_dbhost_access' IDENTIFIED BY '$wp_dbpass';\"",

        }



#    notify { 'note-end-MyConfig':
#            message => 'DB CONFIGURATION FINISHED SUCCESSFULY
#            YOUR DB PARAMETERS
#            DB NAME: $wp_dbname
#            DB USER: $wp_dbuser
#            DB PASS: $wp_dbpass
#            ',
#            require => Exec["WP_DB_Configuration"],
#            }
    }

    else {

    emerg("You skiped MySql configuration")
    }

}
