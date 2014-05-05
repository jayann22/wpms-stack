define wpms_stack::cron() {
	cron { "commit-to-local-git":
		command => "/var/wpms-stack/setup/puppet/modules/wpms_stack/files/cron/commit-to-local-git.sh",
	}
}
