#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: host-local-config.sh
# Author: WKD
# Date: 27NOV8
# Purpose: Script to run on startup of a centos-base docker.
# Use to set the resolv.conf and file system ownership.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
        exit
}

function copyResolv() {
# Error this is still not working, need to download the package with resolvconf command
	if [ -f /etc/resolv.conf.override ]; then
		rm /etc/resolv.conf 
		cp /etc/resolv.conf.override /etc/resolvconf/base
		resolvconf -u
	fi
}

function chownDevuser() {

	if [ -d /home/devuser/bin/hive ]; then
		chown -R devuser:dev /home/devuser
	fi
}

# MAIN
# copyResolv
chownDevuser
