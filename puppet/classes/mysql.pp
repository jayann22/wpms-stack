class mysql {

    $mypkg = [ $mysqlpkg, 'mysql' ]
    
 notify { 'note-install-mysql':
             message => 'STARTING MYSQL INSTALLATION',
             require => Class[ 'apache' ]
        }

    package { $mypkg:
	ensure => present,
	require => Notify[ 'note-install-mysql' ],
    }

    service { $mysqld:
	ensure  => running,
	enable  => true,
	require => Package[ $mypkg ],
    }
     notify { 'note-running-mysql':
        	message => 'RUNNING MYSQL',
        	require => Service[ $mysqld ],
            }
#    exec{"set_root_password":
#         command => "/usr/bin/mysqladmin -u root -p$current_mysqlroot_pass password $set_mysqlroot_pass",
#          require => Service[ $mysqld ],
#        }

}
