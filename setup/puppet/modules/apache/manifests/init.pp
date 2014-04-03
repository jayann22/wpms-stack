class apache {

    $apkg = [ $apache, $phpv, "mod_ssl", "$phpv-mysql" ]



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


  file { "trac-httpd":
        path    => "/etc/httpd/conf/httpd.conf",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('apache/httpd.erb'),
	require => Wordpress::Install-wp['wordpress'],
    }

    service { $apache:
	ensure  => running,
	enable  => true,
	require => File[ 'trac-httpd' ],
	}
	
    notify { 'note-start-apache':
             message => 'RUNNING APACHE',
             require => Service [$apache],
            }
    
}
