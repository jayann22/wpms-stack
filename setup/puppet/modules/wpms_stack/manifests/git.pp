define wpms_stack::git() {
	
	package { "git":
		ensure => installed,
	}

	# **CREDITS**
	# The git-deploy workflow with the post-update & post-commit hooks is based on this blog post from Joe Maller: 
	# http://joemaller.com/990/a-web-focused-git-workflow/
	
	file { "/var/wpms-stack.git/hooks/post-update":
		source => "puppet:///modules/wpms_stack/git/hub-post-update",
		mode => "+x",
		require => Exec["git-clone-bare-repo"],
	}

	file { "/var/wpms-stack/.git/hooks/post-commit":
		source => "puppet:///modules/wpms_stack/git/prime-post-commit",
		mode => "+x",
		require => Exec["git-create-var-wpms-stack-repo"],
	}
	
	exec { "git-clone-bare-repo":
		command => "git clone --bare https://github.com/Link7/wpms-stack.git /var/wpms-stack.git",
		creates => "/var/wpms-stack.git",
		cwd => "/var",
		require => Package["git"],
	}
	
	exec { "git-create-var-wpms-stack-repo":
		command => "git init /var/wpms-stack",
		creates => "/var/wpms-stack/.git",
		require => Package["git"],
	}

	exec { "git-add-hub-remote-to-prime":
		command => "git remote add hub /var/wpms-stack.git",
		cwd => "/var/wpms-stack/",
		unless => "git remote show hub",
		require => Exec["git-create-var-wpms-stack-repo","git-clone-bare-repo"],
	}

	exec { "git-auto-commit-files":
		command => "git add --all && git commit -m 'puppet apply autocommit'",
		cwd => "/var/wpms-stack/",
		onlyif => "git status",
		refreshonly => true,
		require => [ Exec["git-create-var-wpms-stack-repo"], File["/var/wpms-stack/.git/hooks/post-commit"] ],
	}

	# This is unlikely to happen, how could /var/wpms-stack be empty and still be able to run puppet?
#	exec { "git-fix-empty-wpms-stack":
#		command => "git pull hub master",
#		cwd => "/var/wpms-stack",
#		creates => "/var/wpms-stack/README.md",
#		require => Exec["git-create-var-wpms-stack-repo","git-add-hub-remote-to-prime"],
#	}
}
