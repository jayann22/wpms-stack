class apache {

    $apkg = [ $apache, $phpv, "mod_ssl", "$phpv-mysql", "$phpv-mbstring" ]



 notify { 'note-install-apache':
             message => 'STARTING APACHE INSTALLATION',
	}


 notify { 'note-install-finish-apache':
             message => 'APACHE INSTALLATION FINISHED SUCCESSFULLY',
             require => Package [$apkg]
	}
	
    package { $apkg:
	ensure => present,
	require => Notify ['note-install-apache']
    }


    exec { 'service-httpd':
	    notify  => Service [$apache],
    	    command => 'echo ". /etc/profile.d/wpms.sh" >> /etc/sysconfig/httpd',
    	    path => "/bin:/usr/bin",
    	    onlyif => "[ -d /etc/sysconfig -a -z \"$(grep \". /etc/profile.d/wpms.sh\" /etc/sysconfig/httpd)\" ]",
    	    require => Wordpress::Install-wp['wordpress'],

	}

  file { "trac-httpd":
        path    => "/etc/httpd/conf/httpd.conf",
        notify  => Service [$apache],
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('apache/httpd.erb'),
        require => Exec ['service-httpd'], 
    }

    service { $apache:
	ensure => running,
	enable => true,
	require => Notify ['note-start-apache'],
	}
	
    notify { 'note-start-apache':
             message => 'RUNNING APACHE',
	      require => File ['trac-httpd'],
            }
    
}
