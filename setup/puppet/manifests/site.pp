node 'default' {
 case $operatingsystem {
      centos, redhat: { 
#      import 'classes/*.pp'
      import '/tmp/envinit.pp'


include messages
include apache


mysql::install-wp-mysql{"mysqldb":
        wp_dbname => $wrp_dbname,
        wp_dbhost => $wrp_dbhost,
        wp_dbuser => $wrp_dbuser,
        wp_dbpass => $wrp_dbpass,
	wp_mysqladm_user => $wrp_mysqladm_user,
        wp_mysqladm_pass => $wrp_mysqladm_pass,
        wp_mysql_port => $wrp_mysql_port,
        wp_dbhost_access => $wrp_dbhost_access,
	mysqlconf => $mysqlconfigure,
	mysqlinstall => $mysqldinstall,
	require => Notify['note-db-run']
          }

wordpress::install-wp{"wordpress":
        wp_remote_location => $wp_get_address,
        wp_localpath => $wp_local_path,
        wp_apache_localpath => $wp_apache_local_path,
        metod => $wrp_metod,
	web_owner => $wrp_owner,
	web_group => $wrp_group,
	wp_dbhost => $wrp_dbhost,
	wp_dbname => $wrp_dbname,
	wp_dbuser => $wrp_dbuser,
	wp_dbpass => $wrp_dbpass,
	apache_conf => $apache_conf_file,
	wp_admin_user => $wrp_admin_user,
	wp_admin_password => $wrp_admin_password,
	wp_admin_email => $wrp_admin_email,
	wp_title => $wrp_title,
	wp_url => $wrp_url,
	wp_db_prefix => $wrp_db_prefix,
	wp_mysql_port => $wrp_mysql_port,
	wp_plugin_MU => $wrp_plugin_MU,
	wp_subdomain => $wrp_subdomain,
	module_path => "../modules/",
        mode => 0400,
        require => Notify['note-start-WP']
          }

notify { 'note-start-WP':
    	    message => 'INTALLING WP',
        }

notify { 'note-db-run':
            message => 'START DB CONFIGURATION',
            }

Notify[note-install-finish-apache]->Mysql::Install-wp-mysql['mysqldb']-> Notify[note-running-mysql]->Notify['note-db-end']->Wordpress::Install-wp['wordpress']-> Notify['note-wp-end']-> Exec['end-msg']
      }
      debian, ubuntu: { $apache = "apache2" }
      default: {err("Unrecognized operating system") 
    		fail("Unrecognized operating system") 
        }
 }
}
