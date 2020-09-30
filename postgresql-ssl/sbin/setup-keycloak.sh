#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-postgresql.sh
# Author: WKD 
# Date: 20 Apr 2020 
# Purpose: This is a build script to install and configure postgresql
# with the correct databases and access.
# Setup for either Postgresql 9.6 or 10

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
WRKDIR=/usr/local
PGDATA=/var/lib/pgsql/10/data
USERNAME=postgres
DBNAME=postgres
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/setup-postgresql.log

# FUNCTIONS
function usage() {
# usage
	echo "Usage: sudo $(basename $0)"
	exit 1
}

function configPostgreSQL() {
# Configure for keycloak ssl
	if [ -f ${WRKDIR}/conf/postgresql.conf ]; then
		cp ${WRKDIR}/conf/postgresql.conf ${PGDATA}/postgresql.conf
		cp ${WRKDIR}/pki/postgres.crt ${PGDATA}/server.crt
		cp ${WRKDIR}/pki/postgres.key ${PGDATA}/server.key
		chown -R postgres: ${PGDATA} 
		chmod og-rwx ${PGDATA}/server.key
	else
		echo "ERROR: no configuration files in /usr/local/conf" >> ${LOGFILE}
	fi
}

function createDB() {
        psql -v ON_ERROR_STOP=1 --username "${USERNAME}" --dbname "${DBNAME}" <<-EOSQL

        CREATE USER keycloak WITH PASSWORD 'BadPass%1';
        CREATE DATABASE keycloak WITH OWNER keycloak ENCODING 'UTF8' TEMPLATE template0;
        GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;

EOSQL
}

# MAIN
configPostgreSQL
createDB
