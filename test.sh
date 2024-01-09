#!/bin/bash

set -e  # Enables immediate exit if any command returns a non-zero status
set -u  # Treats unset variables as an error when they are encountered
set -o pipefail  # Turns on the option to automatically exit if a pipeline's command has a non-zero status
set -x  # Turns on debugging mode


echo
echo "Printing borg version..."
borg --version

echo
echo "Printing borgmatic version..."
borgmatic --version

echo
echo "Creating borgmatic configuration directory..."
mkdir /tmp/borgmatic

echo
echo "Generating borgmatic configuration..."
borgmatic config generate --destination /tmp/borgmatic/borgmatic.yaml

echo
echo "Showing borgmatic configuration directory..."
ls -alR /tmp/borgmatic

echo
echo "Printing borgmatic configuration..."
cat /tmp/borgmatic/borgmatic.yaml

echo
echo "Validating borgmatic configuration..."
borgmatic config validate --config /tmp/borgmatic/borgmatic.yaml

echo
echo "Editing borgmatic configuration..."
sed -i '/backupserver/d' /tmp/borgmatic/borgmatic.yaml
sed -i '/sourcehostname.borg/d' /tmp/borgmatic/borgmatic.yaml
sed -i '#    - /home#    - /tmp/source##' /tmp/borgmatic/borgmatic.yaml
sed -i '#    - /home#d' /tmp/borgmatic/borgmatic.yaml
sed -i '#    - /etc#d' /tmp/borgmatic/borgmatic.yaml
sed -i '#    - /var/log/syslog#d' /tmp/borgmatic/borgmatic.yaml
sed -i '#    - /home/user/path with spaces#d' /tmp/borgmatic/borgmatic.yaml
sed -i 's#/mnt/backup#/tmp/backup##' /tmp/borgmatic/borgmatic.yaml
echo "encryption_passphrase: PASS" >> /tmp/borgmatic/borgmatic.yaml
cat /tmp/borgmatic/borgmatic.yaml

echo
echo "Printing borgmatic configuration..."
cat /tmp/borgmatic/borgmatic.yaml

echo
echo "Validating borgmatic configuration..."
borgmatic config validate --config /tmp/borgmatic/borgmatic.yaml

echo
echo "Creating source files..."
mkdir -p /tmp/source
dd if=/dev/urandom of=/tmp/source/test.img bs=100000000 count=1

echo
echo "Creating repository directory..."
mkdir -p /tmp/backup

echo
echo "Showing repository directory..."
ls -alR /tmp/backup
du -s /tmp/backup

echo
echo "Running 'borgmatic init'..."
borgmatic init --config /tmp/borgmatic/borgmatic.yaml --verbosity 2 --encryption repokey

echo
echo "Running 'borgmatic create'..."
borgmatic create --config /tmp/borgmatic/borgmatic.yaml --verbosity 2

echo
echo "Updating source files..."
dd if=/dev/urandom of=/tmp/source/test.img bs=100000000 count=1

echo
echo "Running 'borgmatic create' again..."
borgmatic create --config /tmp/borgmatic/borgmatic.yaml --verbosity 2

echo
echo "Running 'borgmatic info'..."
borgmatic info --config /tmp/borgmatic/borgmatic.yaml --verbosity 2

echo
echo "Running 'borgmatic list'..."
borgmatic list --config /tmp/borgmatic/borgmatic.yaml --verbosity 2

echo
echo "Showing repository directory again..."
ls -alR /tmp/backup
du -s /tmp/backup
