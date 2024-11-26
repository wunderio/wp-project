#!/bin/bash

set -euo pipefail

echo "Let's create a new WordPress project"
echo

# Check for dependencies
declare -a DEPENDENCIES=("composer" "jq")

for DEPENDENCY in "${DEPENDENCIES[@]}"; do
    if ! command -v $DEPENDENCY &> /dev/null; then
        echo "$DEPENDENCY could not be found, please install it and try again."
        exit 1
    fi
done

git config --global --add safe.directory '*'

# # Install the Bedrock WordPress boilerplate
composer create-project roots/bedrock temp

# Give temporary directory permissions
chmod 777 temp

# Move into the temporary directory
cd temp

# Patch application.php
patch -p1 -N < ../resources/application.php.patch.1
patch -p1 -N < ../resources/application.php.patch.2

# Define a function to append a value to composer.json scripts array of a given key (or create it if it doesn't exist)
function composer_scripts_add {
    local KEY="$1"
    local VALUE="$2"

    # Check if the key already exists
    local SCRIPT_EXISTS=$(jq -r ".scripts | has(\"$KEY\")" composer.json)

    # If the key exists, append the new value to the array
    if [ "$SCRIPT_EXISTS" == "true" ]; then
        jq --arg key "$KEY" --arg value "$VALUE" '.scripts[$key] += [$value]' composer.json > composer.json.tmp
    # If not, create it as a new array
    else
        jq --arg key "$KEY" --arg value "$VALUE" '.scripts[$key] = [$value]' composer.json > composer.json.tmp
    fi

    # Rename the temporary file back to composer.json
    mv composer.json.tmp composer.json
}

# Set Composer scripts
composer_scripts_add "setup-drop-ins" "cp web/app/plugins/redis-cache/includes/object-cache.php web/app/object-cache.php"
composer_scripts_add "setup-drop-ins" "ln -fs \$(pwd)/web/app/plugins/query-monitor/wp-content/db.php web/app/db.php"
composer_scripts_add "post-install-cmd" "@setup-drop-ins"
composer_scripts_add "post-update-cmd" "@setup-drop-ins"

# Merge our composer.json with the Bedrock composer.json
jq -s ".[0] * .[1]" "composer.json" "../resources/composer.json" > composer.json.tmp
mv composer.json.tmp composer.json

composer config --no-plugins allow-plugins.koodimonni/composer-dropin-installer true

# Install some packages
yes | composer require -n \
    php ">=8.1" \
    wp-cli/wp-cli-bundle \
    wpackagist-plugin/redis-cache \
    wpackagist-plugin/query-monitor \
    koodimonni-language/core-fi \
    koodimonni/composer-dropin-installer \
    10up/elasticpress

# Move all to root directory
cp -r * ../
cd ../
rm -rf temp

# Remove this script
rm create-wp-project.sh

echo "Done!"
