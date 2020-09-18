#!/bin/bash

# Hortonworks University
# This script is for training purposes only and is to be used only
# in support of approved Hortonworks University exercises. Hortonworks
# assumes no liability for use outside of our traning environments.
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Name: create-databases.sh
# Author: WKD
# Date: 170824
# Purpose: This is a build script to create users and databases for
# Hive, Oozie, Ranger, Ranger KMS, and Registery

# DEBUG
# set -x

# VARIABLE
USERNAME=postgres
DBNAME=postgres

# FUNCTIONS
function createDB() {
	psql -v ON_ERROR_STOP=1 --username "${USERNAME}" --dbname "${DBNAME}" <<-EOSQL

	CREATE USER druid WITH PASSWORD 'BadPass%1';
	CREATE DATABASE druid WITH OWNER druid ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE druid TO druid;

	CREATE USER hive WITH PASSWORD 'BadPass%1';
	CREATE DATABASE hive WITH OWNER hive ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE hive TO hive;

	CREATE USER oozie WITH PASSWORD 'BadPass%1';
	CREATE DATABASE oozie WITH OWNER oozie ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE oozie TO oozie;

	CREATE USER rangeradmin WITH PASSWORD 'BadPass%1';
	CREATE DATABASE ranger WITH OWNER rangeradmin ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE ranger TO rangeradmin;

	CREATE USER rangerlogger WITH PASSWORD 'BadPass%1';
	CREATE DATABASE ranger_audit WITH OWNER rangerlogger ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE ranger_audit TO rangerlogger;

	CREATE USER rangerkms WITH PASSWORD 'BadPass%1';
	CREATE DATABASE rangerkms WITH OWNER rangerkms ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE rangerkms TO rangerkms;

	CREATE USER registry WITH PASSWORD 'BadPass%1';
	CREATE DATABASE registry WITH OWNER registry ENCODING 'UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE registry TO registry;

	CREATE USER devuser WITH PASSWORD 'BadPass%1';
	CREATE DATABASE cloudair WITH OWNER devuser ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF8' LC_CTYPE = 'en_US.UTF8' TEMPLATE template0;
	GRANT ALL PRIVILEGES ON DATABASE cloudair TO devuser;

EOSQL
}

# MAIN
createDB
