define wpms_stack::wp() {
	file { "/var/wpms-stack/www/wordpress/wp-content/mu-plugins/wpms-stack-helper.php":
		source => "puppet:///modules/wpms_stack/wp/wpms-stack-helper/wpms-stack-helper.php",
		require => File['/var/wpms-stack/www/wordpress/wp-content/mu-plugins','/var/wpms-stack/www/wpms-stack-plugin-instructions-for-puppet'],
	}

	file { "/var/wpms-stack/www/wordpress/wp-content/mu-plugins":
		ensure => directory,
	}
	
	file { "/var/wpms-stack/www/wpms-stack-plugin-instructions-for-puppet":
		ensure => present,
	}
}
