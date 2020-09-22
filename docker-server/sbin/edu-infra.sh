#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: edu-infra.sh
# Author: WKD
# Date: 200915 
# Purpose: This is the primary script for building out a docker environment
# to support CDP. This script builds images, repo's the images, run the 
# dockers, and start and stop the dockers. See the README.md for details.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
OPTION=$1
OBJECT=$2
DOCKERPATH=${HOME}/src/edu_infra
PASSWORD="BadPass%1"
ADMIN_USER="admin"
ADMIN_PASSWORD="BadPass%1"

# FUNCTIONS
function usage() {
	echo 
        echo "Usage: $(basename $0) [ OPTIONS ] [ OBJECT ]"
	echo 
	echo "Managing Docker containers for infrastructure"
	echo 
        echo "Options:"
	echo "	build [ OBJECT ]    Create Docker images"
	echo "	run   [ OBJECT ]    Run Docker containers"
	echo "	clean		    Clean all images and containers"
	echo "	list		    List networks, images and containers"
	echo "	start		    Start all containers"
	echo "	stop		    Stop all running containers"
	echo "	repo		    Commit images to repo"
	echo 
	echo "Objects:"
	echo "	ansible		    Ansible for CDP"
	echo "	centos		    CentOS w/ systemd" 
	echo "	desktop		    Ubuntu Mate remote desktop"
	echo "	eclipse		    Eclipse IDE"
	echo "	keycloak	    Keycloak for tokins"
	echo "	jenkins		    Jenkins script execution"
	echo "	freeipa		    FreeIPA for Identify Mgmt"
	echo "	postgresql	    RDBMS Postgresql"
	echo 
        exit
}

function callInclude() {
# Test for script and run functions
        if [ -f ${HOME}/sbin/include.sh ]; then
                source ${HOME}/sbin/include.sh
        else
                echo "ERROR: The file ${HOME}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function listImages() {
# list the images
	echo
	docker image ls
	cd ${HOME} 
}

function listContainers() {
# list the images
	echo
	docker container ls
}

function checkCentOS() {
# Check if the CentOS image is available
	docker inspect --type=image wmdailey/security:latest > /dev/null 2>&1

	if [ $? != 0 ]; then
		echo "ERROR: Build the centOS image."
		usage	
	fi
}

function checkNetwork() {
# Check if the Nework is started
	docker inspect --type=network cloudair-bridge > /dev/null 2>&1

	if [ $? != 0 ]; then
		echo "ERROR: Run the network."
		usage
	fi
}

function buildAnsible() {
# Build Ansible and Jenkins Docker images on CentOS base
	checkCentOS
	
	echo "*** BUILDING ANSIBLE ***"
	sleep 2
	cd ${DOCKERPATH}/ansible
	docker image build --tag wmdailey/ansible:latest .
}

function buildCentOS() {
# Build CentOS base
	echo
	echo "*** BUILDING CENTOS-BASE ***"
	sleep 2
	cd ${DOCKERPATH}/centos-base
	docker image build --tag wmdailey/centos-base:latest .

	echo
	echo "*** BUILDING PYTHON ***"
	sleep 2
	cd ${DOCKERPATH}/python
	docker image build --tag wmdailey/python:latest .

	echo
	echo "*** BUILDING SECURITY ***"
	sleep 2
	cd ${DOCKERPATH}/security
	docker image build --tag wmdailey/security:latest .
}

function buildDesktop() {
# build Desktop image on Ubuntu-base
	echo
	echo "*** BUILDING UBUNTU-BASE ***"
	sleep 2
	cd ${DOCKERPATH}/ubuntu-base
	docker image build --tag wmdailey/ubuntu-base:latest .

	echo
	echo "*** BUILDING DESKTOP ***"
	sleep 2
	cd ${DOCKERPATH}/ubuntu-mate
	docker image build --tag wmdailey/desktop:latest .
}


function buildFreeipa() {
# build FreeIPA image on CentOS base
	checkCentOS

	echo
	echo "*** BUILDING FREEIPA ***"
	sleep 2
	cd ${DOCKERPATH}/freeipa
	docker image build --tag wmdailey/freeipa:latest .
}

function buildKeycloak() {
# build Keycloak image on CentOS base
	checkCentOS

	echo
	echo "*** BUILDING KEYCLOAK ***"
	sleep 2
	cd ${DOCKERPATH}/keycloak
	docker image build --build-arg KEYCLOAK_ADMIN=$ADMIN_USER --build-arg KEYCLOAK_PASSWORD=$ADMIN_PASSWORD --tag wmdailey/keycloak:latest .
}

function buildJenkins() {
# Build Jenkins Docker images on CentOS base
	checkCentOS

	echo "*** BUILDING JENKINS ***"
	sleep 2
	cd ${DOCKERPATH}/jenkins
	docker image build --tag wmdailey/jenkins:latest .
}

function buildPostgreSQL() {
# Build PostgreSQL image on CentOS base 
	checkCentOS

	echo "*** BUILDING POSTGRESQL ***"
	sleep 2
	cd ${DOCKERPATH}/postgresql
	docker image build --tag wmdailey/postgresql:latest .
}

function runAnsible() {
# Run the container for Ansible
	checkNetwork

	docker container run -it --detach --privileged \
		--name ansible \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname ansible.cloudair.lan \
		--ip 172.18.0.21  \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--publish 9921:22 \
		--publish 3000:3000 \
		wmdailey/ansible:latest
}

function runCentOS() {
# Run the container for CentOS 
	checkNetwork

	docker container run -it --detach --privileged \
		--name centos \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname "centos.cloudair.lan" \
		--ip 172.18.0.3  \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--publish 9903:22 \
		wmdailey/security:latest
}

function runDesktop() {
# Run desktop to support NoVNC and Mate
	checkNetwork

 	docker container run -it --detach --privileged \
		--name desktop \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname desktop.cloudair.lan \
		--ip 172.18.0.7 \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--env VNC_PASSWORD="BadPass%1" \
		--publish 80:80 \
		--publish 443:443 \
		--publish 5901:5901 \
		wmdailey/desktop:latest
}

function runEclipse() {
# Run Eclipse to support apps development 
	checkNetwork

	sudo mkdir /var/lib/eclipse

	sudo docker container run -it \
		--rm \
		--name eclipse \
		-e CHE_HOST=172.30.0.61 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/lib/eclipse:/data \
		-p 7070:8080 \
		eclipse/che start
		# The CHE_HOST must be set to AWS internal IP
		#eclipse/che info --network 
}

function runFreeipa() {
# Run the container for FreeIPA 
		#--publish 9931:22 \
	checkNetwork

	if [ ! -d /opt/data/ipa ]; then
		sudo mkdir -p /opt/data/ipa 
	fi
 
	sudo docker container run -it --detach --privileged \
		--name freeipa \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname "freeipa.cloudair.lan" \
		--ip 172.18.0.31 \
		--restart unless-stopped \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--volume /opt/data/ipa:/data:Z \
		--tmpfs /tmp:rw \
		--tmpfs /run \
		--publish 9931:22 \
		wmdailey/freeipa:latest
}

function runKeycloak() {
# Run the container for Keycloak
	checkNetwork

        docker container run -it --detach --privileged \
                --name keycloak \
		--shm-size=1gb \
                --network cloudair-bridge \
                --hostname "keycloak.cloudair.lan" \
                --ip 172.18.0.33 \
		-e KEYCLOAK_USER=admin \
		-e KEYCLOAK_PASSWORD=BadPass%1 \
		--restart unless-stopped \
                --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
                --publish 9933:22 \
                --publish 8080:8080 \
                --publish 8443:8443 \
                wmdailey/keycloak:latest
}

function runJenkins() {
# Run the container for Jenkins
	checkNetwork

	docker container run -it --detach --privileged \
		--name jenkins\
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname "jenkins.cloudair.lan" \
		--ip 172.18.0.23 \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--publish 9923:22 \
		wmdailey/jenkins:latest
}

function runNetwork() {
# Create a single network for all dockers, this allows unlimited port access to all 
# dockers on this network. This provides a subnet with up to 61 hosts, the IP range is
# 172.18.0.2 to 172.18.0.254
	# Create_bridge
	docker network create --driver=bridge --subnet=172.18.0.0/24 --ip-range=172.18.0.1/24 cloudair-bridge
	
	docker network ls
}

function runPostgreSQL() {
# Run the docker containers for PostgreSQL 
	checkNetwork

	docker container run -it --detach --privileged \
		--name postgresql \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname "postgresql.cloudair.lan" \
		--ip 172.18.0.5 \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--env HOME=/var/lib/pgsql \
		--env POSTGRESQL_VERSION=10.6 \
		--env POSTGRESQL_DB=postgres \
		--env POSTGRESQL_USER=postgres \
		--env POSTGRESQL_PASSWORD=${PASSWORD} \
		--publish 5432:5432 \
		--publish 9905:22 \
		wmdailey/postgresql:latest
}

function cleanAll() {
# remove dockers, images, and volume
	echo "               *** WARNING WARNING WARNING ***"
	echo "*** CLEANING ALL OBJECTS, NETWORKS, IMAGES, AND VOLUMES ***"
	checkContinue

	docker container rm -f ansible 
	docker container rm -f centos 
	docker container rm -f desktop 
	docker container rm -f freeipa 
	docker container rm -f keycloak
	docker container rm -f jenkins
	docker container rm -f postgresql

	docker rmi $(docker images -q) -f

	docker network rm cloudair-bridge  
}

function listAll() {
# List all images and containers
	echo
	docker network ls
	echo
	listImages
	echo
	listContainers
	echo
}

function startAll() {
# Start docker containers
	docker container start ansible 
	docker container start centos
	docker container start desktop
	docker container start freeipa
	docker container start jenkins
	docker container start keycloak 
	docker container start postgresql 
}

function stopAll() {
# Stop docker containers
	docker container stop ansible 
	docker container stop centos
	docker container stop desktop
	docker container stop freeipa 
	docker container stop jenkins 
	docker container stop keycloak 
	docker container stop postgresql
}

function repoImage() {
# Send images to repo and then delete on the local host
	echo "*** PUSHING IMAGES TO REPO ***"
	echo "*** HAVE YOU LOGGED INTO THE REPO? ***"	
	checkContinue

        docker image push wmdailey/ubuntu-base:latest 
        docker image push wmdailey/desktop:latest 
        docker image push wmdailey/centos-base:latest 
        docker image push wmdailey/python:latest 
        docker image push wmdailey/security:latest 
        docker image push wmdailey/ansible:latest 
        docker image push wmdailey/freeipa:latest 
        docker image push wmdailey/keycloak:latest 
        docker image push wmdailey/jenkins:latest 
        docker image push wmdailey/postgresql:latest 

	echo "      *** WARNING WARNING WARNING ***"
	echo "        *** REMOVING ALL IMAGES ***"	
	checkContinue
	docker rmi $(docker images -q) -f
}

function runOption() {
# Case statements
	if [ -z ${OPTION} ]; then
		usage
	fi

	if [ ${OPTION} == "build" ]; then
		checkArg 2
	
        	case "${OBJECT}" in
                	ansible)
				buildAnsible
				listImages
                        	;;
			centos)
				buildCentOS
				listImages
				;;
                	desktop)
				buildUbuntu
				buildDesktop
				listImages
                        	;;
                	freeipa)
				buildFreeipa
				listImages
                        	;;
			jenkins)
				buildJenkins
				listImages
				;;
			keycloak)
				buildKeycloak
				listImages
				;;
			network)
				runNetwork
				;;
                	postgresql)
				buildPostgreSQL
				listImages
                        	;;
                	*)
                        	usage
                        	;;
		esac
	elif [ ${OPTION} == "run" ]; then
		checkArg 2
	
        	case "${OBJECT}" in
                	ansible)
				runAnsible
				listContainers
                        	;;
			centos)
				runCentOS
				listContainers
				;;
                	desktop)
				runDesktop
				listContainers
                        	;;
                	freeipa)
				runFreeipa
				listContainers
                        	;;
			keycloak)
				runKeycloak
				listContainers
				;;
			jenkins)
				runJenkins
				;;
			network)
				runNetwork
				;;
                	postgresql)
				runPostgreSQL
				listContainers
                        	;;
                	*)
                        	usage
                        	;;
		esac
	else
		checkArg 1

        	case "${OPTION}" in
                	-h | --help)
                        	usage
                        	;;
                	clean)
				cleanAll
                        	;;
			list)
				listAll
				;;
                	start)
				startAll
                        	;;
                	stop)
				stopAll
                        	;;
                	repo)
				repoImage
                        	;;
                	*)
                        	usage
                        	;;
        	esac
	fi
}

# MAIN
# Source functions in include
callInclude

# Run checks
checkSudo

# Run option
runOption
