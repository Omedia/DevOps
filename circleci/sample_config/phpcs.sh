#!/bin/bash

# Checks if its a pull request
if [[ -z "${CIRCLE_PULL_REQUEST}" ]];
then
	echo "This is not a pull request, no PHPCS needed."
	exit 0
else
	echo "This is a pull request, continuing"
fi

# Gets list of changed files in GIT (except of deleted files, as phpcs tests cannot check deleted files, that makes a sense)
echo "Getting list of changed files..."
changed_files=$(git diff-tree --no-commit-id --name-only --diff-filter=d -r HEAD)

if [[ -z $changed_files ]]
then
	echo "There are no files to check."
	exit 0
fi

# Prints all the changed files
echo "$changed_files"

# Including drupal coder to phpcs`s standarts
echo "Registering drupal standarts"
./vendor/bin/phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer

# Prints all the coding standarts, included in phpcs
echo "Checking installed paths"
./vendor/bin/phpcs -i

# Phpcs tests are being executed now on changed files
echo "Running phpcs..."
./vendor/bin/phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md $changed_files

