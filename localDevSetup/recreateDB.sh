#!/bin/bash

# This file is part of Archivematica.
#
# Copyright 2010-2013 Artefactual Systems Inc. <http://artefactual.com>
#
# Archivematica is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Archivematica is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Archivematica.  If not, see <http://www.gnu.org/licenses/>.

# @package Archivematica
# @author Joseph Perry <joseph@artefactual.com>
# @version svn: $Id$

databaseName="MCP"
currentDir="$(dirname $0)"
username="archivematica"
password="demo"

echo "Removing existing units"
sudo ./removeUnitsFromWatchedDirectories.py
sudo rm -rf /var/archivematica/sharedDirectory/tmp/tmp*
sudo rm -rf /var/archivematica/sharedDirectory/www/thumbnails/*

# Delete pyc's & pyo's
find ../src -name '*.py[o|c]' -delete

set -e
echo -n "Enter the DATABASE root password (Hit enter if blank):"
read dbpassword

if [ ! -z "$dbpassword" ] ; then
    dbpassword="-p${dbpassword}"
else
    dbpassword=""
fi
#set -o verbose #echo on
pwd
currentDir="`dirname $0`"
set +e
echo "Removing the old database"
mysql -u root "${dbpassword}" --execute="DROP DATABASE IF EXISTS ${databaseName}"
echo "Removing ${username} user"
mysql -u root "${dbpassword}" --execute="DROP USER '${username}'@'localhost';"
set -e

echo "Creating MCP database"
mysql -u root "${dbpassword}" --execute="CREATE DATABASE ${databaseName} CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
echo "Creating ${username} user"
mysql -u root "${dbpassword}" --execute="CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';"
mysql -u root "${dbpassword}" --execute="GRANT SELECT, UPDATE, INSERT, DELETE, CREATE, ALTER, INDEX ON ${databaseName}.* TO '${username}'@'localhost';"

echo "Creating and populating MCP tables"

# Run Django's syncdb
../src/dashboard/src/manage.py migrate --noinput --settings='settings.local'


dbpassword=""

#set +o verbose #echo off
printGreen="${databaseName} database created successfully."
echo -e "\e[6;32m${printGreen}\e[0m"
