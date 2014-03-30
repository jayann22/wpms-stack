class extra {

    $expkg = [ "wget", "tar", "git", "curl" ]
    package { $expkg:
	ensure => present,
#	require => Class["mysql"]
    }
}