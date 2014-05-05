class extra {

    $expkg = [ "wget", "tar", "curl" ]
    package { $expkg:
	ensure => present,
#	require => Class["mysql"]
    }
}
