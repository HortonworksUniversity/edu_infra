# edu_infra
Administrative environment in support of edu_auto_prov. 

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
	* PostgreSQL v10
	* Ansible 
	* Eclipse
	* FreeIPA
	* Jenkins
	* Keycloak

## 
The CentOS dockers containers install initd to allow simulation similar
to a virtual machine. This includes ssh login.
