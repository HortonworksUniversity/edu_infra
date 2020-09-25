# edu_infra
Administrative environment in support of edu_auto_prov. 

## Docker Containers
Docker containers for 
	* Desktop
		- Ubuntu 20.04
		- Mate 
	* CentOS v7.8
		- OpenJava v1.8.0
		- JDBC PostgreSQL 42.2.12 
		- Python 3.6
		- Security packages for LDAP, KDC, SSSD
		- User sysadmin 
	* Ansible 
	* Eclipse
	* FreeIPA
	* Jenkins
	* Keycloak
	* PostgreSQL v10

## CentOS
The dockers containers for centos builds with three layers. There is a centos-base layer, containing common packages, Java, and the JDBC. The administrative user sysadmin is created granting sudo with no password. There is the python layer for python 3. There is the security layer containing all of the common security packages. The centos-base does install the common work around of systemd. There are several docker containers which require this functionality. This also gives us the ability to ssh into a docker.
	% ssh sysadmin@centos
	% ssh sysadmin@postgresql

## PostgreSQL
The PostgreSQL RDBMS creates standard databases with character set UTF8. 
	* devuser/cloudair
	* hive/hive
	* keycloak/keycloak
	* rangeradmin/ranger
	* rangerkms/rangerkms
	* registry/registry
	
