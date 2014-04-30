define wordpress::install-wp($wp_remote_location, $mode = 0644, $wp_localpath, $metod = 'GIT', $module_path, $wp_db_prefix, $wp_subdomain,
		    $wp_admin_email, $web_owner, $web_group, $wp_dbhost, $wp_dbname, $wp_dbuser, $wp_dbpass, $apache_conf, $wp_config_path,
		    $wp_admin_user, $wp_admin_password, $wp_title, $wp_url, $wp_mysql_port, $wp_plugin_MU, $wp_apache_localpath, $wp_env ){
#    include apache
    include extra
    
  $tmppath = "/tmp/${title}.tar.gz"
  
    if $metod == 'WEB' { 
	    $command = "/usr/bin/wget -q --no-check-certificate ${wp_remote_location} -O ${$tmppath}" 

  file{"${tmppath}":
    ensure => absent,
    mode => $mode,
    require => File["${wp_apache_localpath}"],
  }
  
    file { "${wp_apache_localpath}":
	ensure => 'linke',
      target => "${wp_localpath}",
      require => Exec["wp-cli-install"],
      }
      
      exec{"wp-cli-install":
        command => "/bin/cp $module_path/../setup/puppet/modules/wordpress/files/wpcli /tmp/ \
    	&& if [ -f $wp_config_path/$wp_env-wp-config.php ]; then /bin/sed -i \"s/define( 'SUNRISE', 'on' );//g\" $wp_config_path/$wp_env-wp-config.php \
    		 && mv $wp_config_path\\/$wp_env-wp-config.php $wp_localpath/wp-config.php; \
		 if [ $wp_subdomain == \"Yes\" ]; then /bin/cp $module_path/../setup/puppet/modules/wordpress/templates/htaccesSubdomain.erb $wp_localpath/.htaccess; \
		 /usr/bin/php /tmp/wpcli core multisite-install --subdomains --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; \
		 else /bin/cp $module_path/../setup/puppet/modules/wordpress/templates/htaccesSubfolder.erb $wp_localpath/.htaccess; \
		 /usr/bin/php /tmp/wpcli core multisite-install --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; fi; \
		 if [ $wp_plugin_MU == \"Yes\" ]; then /usr/bin/php /tmp/wpcli plugin install \"WordPress MU Domain Mapping\" --path=$wp_localpath; \
		 /bin/mv $wp_localpath/wp-content/plugins/wordpress-mu-domain-mapping/sunrise.php $wp_localpath/wp-content/; \
		 /bin/sed -i \"/define('ABSPATH', dirname(__FILE__) . '\\/');/a define( 'SUNRISE', 'on' );\" $wp_localpath/wp-config.php; fi; \
	else rm -f $wp_localpath/wp-config.php; \
		 /usr/bin/php /tmp/wpcli core config --path=$wp_localpath --dbname=$wp_dbname --dbuser=$wp_dbuser --dbpass=$wp_dbpass --dbhost=$wp_dbhost:$wp_mysql_port --dbprefix=$wp_db_prefix; \
		 /usr/bin/php /tmp/wpcli db reset --path=$wp_localpath --yes; \
		 if [ $wp_subdomain == \"Yes\" ]; then /bin/cp $module_path/../setup/puppet/modules/wordpress/templates/htaccesSubdomain.erb $wp_localpath/.htaccess; \
		 /usr/bin/php /tmp/wpcli core multisite-install --subdomains --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; \
		 else /bin/cp $module_path/../setup/puppet/modules/wordpress/templates/htaccesSubfolder.erb $wp_localpath/.htaccess; \
		 /usr/bin/php /tmp/wpcli core multisite-install --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; fi; \
		 if [ $wp_plugin_MU == \"Yes\" ]; then /usr/bin/php /tmp/wpcli plugin install \"WordPress MU Domain Mapping\" --path=$wp_localpath; \
		 /bin/mv $wp_localpath/wp-content/plugins/wordpress-mu-domain-mapping/sunrise.php $wp_localpath/wp-content/; \
		 /bin/sed -i \"/define('ABSPATH', dirname(__FILE__) . '\\/');/a define( 'SUNRISE', 'on' );\" $wp_localpath/wp-config.php; fi; \
	    fi \
    	&& /bin/mv $wp_localpath/wp-config.php $wp_config_path\\/$wp_env-wp-config.php \
    	&& /bin/cp $module_path/../setup/puppet/modules/wordpress/templates/wp-config.erb $wp_localpath/wp-config.php \
	&& /bin/chown -R $web_owner.$web_group $wp_localpath \
	&& rm -fr /tmp/wpcli",
	path => "/bin:/usr/bin",
#	onlyif => "[ -d $wp_config_path -a -z \"$(ls $wp_config_path\\/$wp_env-wp-config.php)\" ]",
	require => Exec["get_web_${tmppath}"],
      }
      
  exec{"get_web_${$tmppath}":
  
	    command => "$command \
			&& /bin/tar -zxf $tmppath -C $wp_localpath --strip-components 1 \
			&& /bin/rm -f $tmppath",
	    require => Notify[ note-wp-download ],
#	    subscribe => File["$tmppath"],
	    timeout => '600',
#	    refreshonly => true,
	    path => "/bin:/usr/bin",
	    onlyif => "[ -d $wp_localpath -a -z \"$(ls -A -I '.gitkeep' $wp_localpath)\" ]",
#	    onlyif => "[ -d $wp_localpath -a -z \"$(ls $wp_localpath\\/wp-config.php)\" ]",
    }

 file{"${wp_localpath}":
        ensure => "directory",
        require => Class["extra"],
           }
           
    notify { 'note-wp-download':
             message => 'DOWNLOADING WP from WEB...',
             require => File[ $wp_localpath ],
            }

    }
    elsif $metod == 'GIT' {
	    $command = "/usr/bin/git clone ${wp_remote_location} ${wp_localpath}"
	    
    file{"${wp_localpath}":
	    ensure => "directory",
	    require => Class["extra"],
#	    require => File["${wp_apache_localpath}"],
	}

    file { "${wp_apache_localpath}":
	ensure => 'linke',
      target => "${wp_localpath}",
      require => Exec["wp-cli-install"],
      }
      
      exec{"wp-cli-install":
        command => "/bin/cp $module_path/wordpress/files/wpcli /tmp/ \
		&& if [ $wp_subdomain == \"Yes\" ]; then /usr/bin/php /tmp/wpcli core multisite-install --subdomains --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; \
		else /usr/bin/php /tmp/wpcli core multisite-install --path=$wp_localpath --url=$wp_url --title=\"$wp_title\" --admin_user=$wp_admin_user --admin_password=$wp_admin_password --admin_email=$wp_admin_email; fi \
		&& if [ $wp_plugin_MU == \"Yes\" ]; then /usr/bin/php /tmp/wpcli plugin install \"WordPress MU Domain Mapping\" --path=$wp_localpath; \
		/bin/mv $wp_localpath/wp-content/plugins/wordpress-mu-domain-mapping/sunrise.php $wp_localpath/wp-content/; \
		/bin/sed -i \"/define('ABSPATH', dirname(__FILE__) . '\\/');/a define( 'SUNRISE', 'on' );\" $wp_localpath/wp-config.php; fi \
		&& /bin/cp $module_path/wordpress/templates/wp-config.erb $wp_localpath/wp-config.php \
		&& /bin/chown -R $web_owner.$web_group $wp_localpath \
		&& rm -fr /tmp/wpcli",
	path => "/bin:/usr/bin",
	onlyif => "[ -d $wp_config_path -a -z \"$(ls $wp_config_path\\/$wp_env-wp-config.php)\" ]",
	require => Exec["get_git_${wp_localpath}"],
      }

  exec{"get_git_${wp_localpath}":
	    command => "$command \
			&& /bin/cp $module_path/wordpress/files/wpcli /tmp/ \
			&& /usr/bin/php /tmp/wpcli core config --path=$wp_localpath --dbname=$wp_dbname --dbuser=$wp_dbuser --dbpass=$wp_dbpass --dbhost=$wp_dbhost:$wp_mysql_port --dbprefix=$wp_db_prefix \
			&& if [ $wp_subdomain == \"Yes\" ]; then /bin/cp $module_path/wordpress/templates/htaccesSubdomain.erb $wp_localpath/.htaccess; \
			else /bin/cp $module_path/wordpress/templates/htaccesSubfolder.erb $wp_localpath/.htaccess; fi \
			&& rm -fr $wp_localpath/.git \
			&& rm -fr /tmp/wpcli",
#			require => Class["extra"],
			require => Notify[ note-wp-download-git ],
			timeout => '600',
			path => "/bin:/usr/bin",
#			&& /bin/sed -i \"/define('WP_DEBUG', false);/a define( 'WP_ALLOW_MULTISITE', true );\" $wp_localpath/wp-config-sample.php \
			onlyif => "[ -d $wp_localpath -a -z \"$(ls -A $wp_localpath)\" ]",
	}

    notify { 'note-wp-download-git':
             message => 'DOWNLOADING WP from GIT...',
             require => File[ $wp_localpath ],
            }
	
    }
    else {

    err("You puted getting metod $metod it should be WEB or GIT")
    fail("You puted getting metod $metod it should be WEB or GIT")
    }


#if $name =~ /^(et|ep)/ {
#      $app = "echos"
#      notice('app is $app')
#        }
#Notify['note-db-start']-> Exec['WP_DB_Configuration']-> Notify['note-db-end']

}
