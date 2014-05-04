#!/bin/bash


grep -iq 'git-commit-now: yes' /var/wpms-stack/www/wpms-stack-plugin-instructions-for-puppet && FOUND='Yes' || exit

cd /var/wpms-stack/
git status

git add --all
git commit

sed -i 's/git-commit-now: Yes/git-commit-now: No/g' /var/wpms-stack/www/wpms-stack-plugin-instructions-for-puppet
