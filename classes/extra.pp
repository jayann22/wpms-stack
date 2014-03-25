class extra {

    $expkg = [ "wget", "tar", "git" ]
    package { $expkg:
	ensure => present,
	require => Class["apache"]
    }
}