node 'default' {
 case $operatingsystem {
      centos, redhat: { 
      import 'classes/*.pp'

include messages

install_wp_mysql{"mysqldb":
        wp_dbname => $wrp_dbname,
        wp_dbuser => $wrp_dbuser,
        wp_dbpass => $wrp_dbpass,
        wp_dbhost_access => $wrp_dbhost_access,
	mysqlconf => $mysqlconfigure,
	mysqlinstall => $mysqldinstall,
	require => notify['note-db-run']
          }

install_wp{"wordpress":
        wp_remote_location => $wp_get_address,
        wp_localpath => $wp_local_path,
        metod => $wrp_metod,
	web_owner => $wrp_owner,
	web_group => $wrp_group,
        mode => 0400,
        require => notify['note-start-WP']
          }

notify { 'note-start-WP':
    	    message => 'INTALLING WP',
        }

notify { 'note-db-run':
            message => 'START DB CONFIGURATION',
            }

    Install_wp['wordpress']-> Notify['note-wp-end']->Install_wp_mysql['mysqldb']->Notify['note-db-end']-> Notify['note-end']
      }
      debian, ubuntu: { $apache = "apache2" }
      default: {err("Unrecognized operating system") 
    		fail("Unrecognized operating system") 
        }
 }
}
