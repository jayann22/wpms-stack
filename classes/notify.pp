class messages {


    notify { 'note-db-end':
	message => 'END OF DB CONFIGURATION',
        }
        
    notify { 'note-wp-end':
        message => 'END OF WP INSTALLATION',
	}

    notify { 'note-end':
        message => 'INSTALATION FINISHED SUCCESSFULY',
        }

}
