#!/bin/bash

echo "Let's create a new WordPress project"
echo

# Check for dependencies
declare -a DEPENDENCIES=("composer" "jq" "lando")

for DEPENDENCY in "${DEPENDENCIES[@]}"; do
    if ! command -v $DEPENDENCY &> /dev/null; then
        echo "$DEPENDENCY could not be found, please install it and try again."
        exit 1
    fi
done

# Get the current directory name and use it as the project name default
PROJECT_NAME=${PWD##*/}

# Ask the user for the Lando domain name
echo "Enter a domain name prefix for Lando [$PROJECT_NAME]: "
read DOMAIN_NAME
echo

# If the user didn't enter a domain name, use the project name
if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME=$PROJECT_NAME
fi

# Install the Bedrock WordPress boilerplate
composer create-project roots/bedrock temp

# Move into the temporary directory
cd temp

# Patch application.php to use dynamic URLs with resources/application.php.patch.1
patch -p1 -N < ../resources/application.php.patch.1

# Install some packages
composer require wp-cli/wp-cli-bundle wpackagist-plugin/redis-cache wpackagist-plugin/query-monitor

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

# Move all to root directory
cp -r * ../
cd ../
rm -rf temp

# Replace the domain name in the Lando config
sed -i '' "s/%PROJECT_NAME%/$DOMAIN_NAME/g" .lando/.lando.yml

# Move the Lando config to the root directory
mv .lando/.lando.yml .

# Remove this script
rm create-wp-project.sh

echo "Done!"