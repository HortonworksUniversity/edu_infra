#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Name: setup-ubuntu-docker.sh
# Author: WKD
# Date: 200915 
# Purpose: Setup admin env in support of auto_prov project. 
# Note: This script is configured for ubuntu. You have
# to edit the changes when changing the OS.
# Note: This script is setup to pull from the GitHub repo on HWU. It
# is intended to use HTTPS. If you have a ssh key you can edit for
# passwordless ssh.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DOCKERBRANCH=develop

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
        exit
}

function callInclude() {
# Test for script and run include
        if [ -f ${HOME}/sbin/include.sh ]; then
                source ${HOME}/sbin/include.sh
        else
                echo "ERROR: The file ${HOME}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function installSoftware() {
# Install software on the students hosts
	${HOME}/sbin/install-docker.sh
	sudo usermod -aG docker ubuntu

	echo "*** Install Docker Compose ***"
	sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

	suod apt-get install -y vim
	sudo apt-get update
	sudo apt-get clean -y

	sudo cp ${HOME}/conf/motd /etc
}

function appendHosts() {
# Append to hosts file 
	sudo cat /etc/hosts ${HOME}/conf/hosts >> /tmp/hosts 
	sudo mv /tmp/hosts /etc/hosts
	cat /etc/hosts
}

function sshFile() {
# Copy in the private key on the students hosts
        cp ${HOME}/pki/id_rsa ${HOME}/.ssh/id_rsa
        cp ${HOME}/pki/id_rsa.pub ${HOME}/.ssh/id_rsa.pub
        chmod 600 ${HOME}/.ssh/id_rsa
}

function bashFile() {
# Copy in the bash files on the students hosts
        cp ${HOME}/conf/bash_profile ${HOME}/.bash_profile
       	cp ${HOME}/conf/bashrc ${HOME}/.bashrc
}

function setupInit() {
# Install script for auto start
	sudo cp ${HOME}/sbin/rc.local /etc/rc.local
	sudo chmod 755 /etc/rc.local
}

function setupGit() {
# This is pulling from the GitHub. The option for https is here, but
# the preferred is using ssh without a password.
	mkdir -p ${HOME}/src
	cd ${HOME}/src/
	git clone --single-branch --branch ${DOCKERBRANCH} git@github.infra.cloudera.com:EDU/edu_admin_env.git
	chown -R ubuntu:ubuntu ${HOME} 
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo

# Run
installSoftware
appendHosts
sshFile
bashFile
setupInit
setupGit
