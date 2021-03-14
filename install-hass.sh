#!/bin/bash

# Simple script which updates home assistant core repository and installs it
# in a python virtual environment. Currently this only tracks the dev branch
# since its all I care about at the moment.
#
# The script assumes that systemd is used, and that its installed with a service
# name of "hass". It also assumes the system account name is hass. There are
# reference files included in the repository that can be used.

HASS_GIT=~/hass-core
HASS_HOME=/usr/lib/hass
HASS_DATA=/var/lib/hass

if [[ ! -d $HASS_GIT ]]; then
  echo "Cloning dev repository"
  git clone https://github.com/home-assistant/core.git $HASS_GIT
else
  echo "Updating repo"
  pushd $HASS_GIT
  git fetch
  git pull
  popd
fi

# Stop Home assistant
systemctl stop hass

# Blow away old install
rm -rf $HASS_HOME

# Create new one venv
python3 -m venv $HASS_HOME

# Update pip (Base ubuntu pip3 doesn't resolve dependencies correctly anymore)
${HASS_HOME}/bin/pip install --upgrade pip==20.3.0

# Install code to virtual env
#/usr/lib/hass/bin/python ~/hass-core/setup.py install --root=/ --prefix=/usr/lib/hass --optimize=1
${HASS_HOME}/bin/pip install $HASS_GIT

# Install required libraries
${HASS_HOME}/bin/pip install -r ${HASS_GIT}/requirements.txt
#--use-feature=2020-resolver

# Fix permissions
chown -R hass:hass ${HASS_HOME}

# Start hass
systemctl start hass
