# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM wmdailey/python:latest
MAINTAINER WKD 

# Install repos and update 
RUN yum install -y epel-release  
# System packages 
RUN yum install -y \
	adcli \
	authconfig \
	bind-utils \
	ca-certificates \
	kkbind-utils \
	krb5-workstation \
	ntp \
	ntpdate \
	oddjob-mkhomedir \
	openldap-clients \
	openssl \
	sssd \
	sssd-ad \
	sssd-krb5 \
	sssd-tools 
RUN yum update -y && yum clean all

# System configure
RUN systemctl enable ntpd 

# Configure pki
RUN mkdir -p /etc/pki/ca-trust/source/anchors
ADD pki/ldap-cert.pem /etc/pki/ca-trust/source/anchors/hortonworks-net.crt
ADD pki/ldap-cert.pem /etc/openldap/certs/ldap-cert.pem
ADD pki/cacert.pem /etc/openldap/certs/cacert.pem
ADD conf/ldap.conf /etc/openldap/ldap.conf
RUN update-ca-trust force-enable
RUN update-ca-trust extact
RUN update-ca-trust check

# Add resolv.conf file to be copied over after start up
ADD conf/resolv.conf /etc/resolv.conf.override
ADD sbin/local-host-config.sh /usr/local/sbin/local-host-config.sh

# Add Kerberos Config
ADD conf/krb5.conf /etc/krb5.conf
