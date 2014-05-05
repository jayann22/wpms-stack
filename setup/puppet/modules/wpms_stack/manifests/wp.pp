define wpms_stack::wp() {
	file { "/var/wpms-stack/www/wordpress/wp-content/mu-plugins/wpms-stack-helper.php":
		source => "puppet:///modules/wpms_stack/wp/wpms-stack-helper/wpms-stack-helper.php",
		require => File['/var/wpms-stack/www/wordpress/wp-content/mu-plugins','/var/wpms-stack/internal/wpms-stack-plugin-instructions-for-puppet'],
	}

	file { ["/var/wpms-stack/www/wordpress/wp-content/mu-plugins","/var/wpms-stack/internal"]:
		ensure => directory,
	}
	
	file { "/var/wpms-stack/internal/wpms-stack-plugin-instructions-for-puppet":
		ensure => present,
		owner => "apache",
		group => "apache",
		require => File["/var/wpms-stack/internal"],
	}

	#delete previous file, can remove this again when everyone has updated
	file { "/var/wpms-stack/www/wpms-stack-plugin-instructions-for-puppet":
		ensure => absent,
	}
}
