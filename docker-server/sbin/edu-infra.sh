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
CONTAINER=$2
DOCKERPATH=${HOME}/src/edu_infra
PASSWORD="BadPass%1"

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [ repo|clean|start|stop ]"
        echo "                    [ build ansible|desktop|ipa|postgresql ]"
        echo "                    [ run network|ansible|desktop|ipa||postgresql ]"
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

function buildAnsible() {
# Build Ansible and Jenkins Docker images on CentOS base

	echo "*** BUILDING ANSIBLE ***"
	sleep 2
	cd ${DOCKERPATH}/ansible
	docker image build --tag wmdailey/ansible:latest .

}

function buildJenkins() {
# Build Jenkins Docker images on CentOS base

	echo "*** BUILDING JENKINS ***"
	sleep 2
	cd ${DOCKERPATH}/jenkins
	docker image build --tag wmdailey/jenkins:latest .
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


function buildIPA() {
# build FreeIPA image on CentOS base
	
	echo
	echo "*** BUILDING FREEIPA ***"
	sleep 2
	cd ${DOCKERPATH}/freeipa
	docker image build --tag wmdailey/freeipa:latest .
}

function buildKeycloak() {
# build Keycloak image on CentOS base
	
	echo
	echo "*** BUILDING KEYCLOAK ***"
	sleep 2
	cd ${DOCKERPATH}/keycloak
	docker image build --tag wmdailey/keycloak:latest .

}

function buildPostgreSQL() {
# Build PostgreSQL image on CentOS base 

	echo "*** BUILDING POSTGRESQL ***"
	sleep 2
	cd ${DOCKERPATH}/postgresql
	docker image build --tag wmdailey/postgresql:latest .
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

function cleanAll() {
# remove dockers, images, and volume
	echo "               *** WARNING WARNING WARNING ***"
	echo "*** CLEANING ALL CONTAINERS, NETWORKS, IMAGES, AND VOLUMES ***"
	checkContinue

	docker container rm -f ansible 
	docker container rm -f desktop 
	docker container rm -f freeipa 
	docker container rm -f keycloak
	docker container rm -f jenkins
	docker container rm -f postgresql

	docker rmi $(docker images -q) -f

	docker network rm cloudair-bridge  
}

function runNetwork() {
# Create a single network for all dockers, this allows unlimited port access to all 
# dockers on this network. This provides a subnet with up to 61 hosts, the IP range is
# 172.18.0.2 to 172.18.0.254

	# Create_bridge
	docker network create --driver=bridge --subnet=172.18.0.0/24 --ip-range=172.18.0.1/24 cloudair-bridge
}

function runAnsible() {
# Run the container for Ansible

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

function runJenkins() {
# Run the container for Jenkins

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

function runDesktop() {
# Run desktop to support NoVNC and Mate

 	docker container run -it --detach --privileged \
		--name desktop \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname desktop.cloudair.lan \
		--ip 172.18.0.51 \
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

	# Make directory for Eclipse
	sudo mkdir /var/lib/eclipse

	# Run Eclipse 
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

function runIPA() {
# Run the container for FreeIPA 
	
		#--publish 9931:22 \

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
		wmdailey/freeipa:latest
}

function runKeycloak() {
# Run the container for Keycloak
  
        docker container run -it --detach --privileged \
                --name keycloak \
		--shm-size=1gb \
                --network cloudair-bridge \
                --hostname "keycloak.cloudair.lan" \
                --ip 172.18.0.33 \
		--restart unless-stopped \
                --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
                --publish 9933:22 \
                wmdailey/keycloak:latest
}

function runPostgreSQL() {
# Run the docker containers for PostgreSQL 

	# Run db01 to support central PostgreSQL RDBMS
	docker container run -it --detach --privileged \
		--name postgresql \
		--shm-size=1gb \
		--network cloudair-bridge \
		--hostname "postgresql.cloudair.lan" \
		--ip 172.18.0.3 \
		--restart unless-stopped \
		--volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
		--env HOME=/var/lib/pgsql \
		--env POSTGRESQL_VERSION=10.6 \
		--env POSTGRESQL_DB=postgres \
		--env POSTGRESQL_USER=postgres \
		--env POSTGRESQL_PASSWORD=${PASSWORD} \
		--publish 5432:5432 \
		--publish 9903:22 \
		wmdailey/postgresql:latest
}

function startAll() {
# Start docker containers

	docker container start ansible 
	docker container start desktop
	docker container start freeipa
	docker container start jenkins
	docker container start keycloak 
	docker container start postgresql 
}

function stopAll() {
# Stop docker containers

	docker container stop ansible 
	docker container stop desktop
	docker container stop freeipa 
	docker container stop jenkins 
	docker container stop keycloak 
	docker container stop postgresql
}

function runOption() {
# Case statement 

	if [ -z ${OPTION} ]; then
		usage
	fi

	if [ ${OPTION} == "build" ]; then
		checkArg 2
	
        	case "${CONTAINER}" in
                	ansible)
				buildCentOS
				buildAnsible
				buildJenkins
				listImages
                        	;;
                	desktop)
				buildDesktop
				listImages
                        	;;
                	ipa)
#				buildCentOS
				buildIPA
				#buildKeycloak
				listImages
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
	
        	case "${CONTAINER}" in
			network)
				runNetwork
				;;
                	ansible)
				runAnsible
				runJenkins
				listContainers
                        	;;
                	desktop)
				runDesktop
				listContainers
                        	;;
                	ipa)
				runIPA
#				runKeycloak
				listContainers
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
                	repo)
				repoImage
                        	;;
                	clean)
				cleanAll
                        	;;
                	start)
				startAll
                        	;;
                	stop)
				stopAll
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
