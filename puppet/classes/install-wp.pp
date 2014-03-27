define install_wp($wp_remote_location, $mode = 0644, 
		    $wp_localpath, $metod = 'GIT', $web_owner, $web_group){
    include apache
    include extra
    
  $tmppath = "/tmp/${title}.tar.gz"
  
    if $metod == 'WEB' { 
	    $command = "/usr/bin/wget -q --no-check-certificate ${wp_remote_location} -O ${$tmppath}" 

  file{"${tmppath}":
    ensure => absent,
    mode => $mode,
    require => Exec["get_web_${tmppath}"],
  }

  exec{"get_web_${$tmppath}":
  
	    command => "$command \
			&& /bin/tar -zxf $tmppath -C $wp_localpath --strip-components 1 \
			&& /bin/rm -f $tmppath \
			&& /bin/chown -R $web_owner.$web_group $wp_localpath \
			&& /bin/sed -i \"/define('WP_DEBUG', false);/a define( 'WP_ALLOW_MULTISITE', true );\" $wp_localpath/wp-config-sample.php",
#	    creates => "${tmppath}",
	    require => Notify[ note-wp-download ],
#	    subscribe => File["$tmppath"],
#	    refreshonly => true,
	    path => "/bin:/usr/bin",
	    onlyif => "[ -d $wp_localpath -a -z \"$(ls -A $wp_localpath)\" ]",
    }

 file{"${wp_localpath}":
        ensure => "directory",
        require => Class["extra"],
           }
           
    notify { 'note-wp-download':
             message => 'DOWNLOADING WP from WEB',
             require => File[ $wp_localpath ],
            }

    }
    elsif $metod == 'GIT' {
	    $command = "/usr/bin/git clone ${wp_remote_location} ${wp_localpath}"
	    
    file{"${wp_localpath}":
	    ensure => "directory",
	    require => Class["extra"],
#	    require => Exec["get_git_${wp_localpath}"],
	}
	
  exec{"get_git_${wp_localpath}":
	    command => "$command \
			&& /bin/chown -R $web_owner.$web_group $wp_localpath \
			&& rm -fr $wp_localpath/.git \
			&& /bin/sed -i \"/define('WP_DEBUG', false);/a define( 'WP_ALLOW_MULTISITE', true );\" $wp_localpath/wp-config-sample.php",
#			require => Class["extra"],
			require => Notify[ note-wp-download-git ],
			path => "/bin:/usr/bin",
			onlyif => "[ -d $wp_localpath -a -z \"$(ls -A $wp_localpath)\" ]",
	}

    notify { 'note-wp-download-git':
             message => 'DOWNLOADING WP from GIT',
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
