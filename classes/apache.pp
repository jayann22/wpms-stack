class apache {
    $apkg = [ $apache, $phpv, "mod_ssl", "$phpv-mysql" ]

 notify { 'note-install-apache':
             message => 'STARTING APACHE INSTALLATION',
	}
	
    package { $apkg:
	ensure => present,
	require => Notify ['note-install-apache']
    }

    service { $apache:
	ensure  => running,
	enable  => true,
	require => Package[ $apkg ],
	}
	
    notify { 'note-start-apache':
             message => 'RUNNING APACHE',
             require => Service [$apache],
            }
    
}
