class messages {


    notify { 'note-db-end':
	message => 'END OF DB CONFIGURATION',
        }
        
    notify { 'note-wp-end':
        message => 'END OF WP INSTALLATION',
	}
    
    exec { 'end-msg':
            path      => '/bin',
	    command   => "echo -e \"\\033[1mINSTALATION FINISHED SUCCESSFULY\n\\033[1mURL: $wrp_url\n\\033[1mUSER: $wrp_admin_user\n\\033[1mPASSWORD: $wrp_admin_password\"",
            logoutput => true,
        }

}
