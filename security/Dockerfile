# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM wmdailey/python:latest

# Labels
LABEL maintainer="William Dailey <wdailey@cloudera.com>"
LABEL org.label-schema.description="Centos 7 image with security packages"
LABEL org.label-schema.version="Centos 7.8 Security"

# Install security packages 
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
	sssd-tools && \
	yum update -y && yum clean all

# System configure
RUN systemctl enable ntpd 

# Configure pki in support of HDP ssl
RUN mkdir -p /etc/pki/ca-trust/source/anchors
ADD pki/ldap-cert.pem /etc/pki/ca-trust/source/anchors/hortonworks-net.crt
ADD pki/ldap-cert.pem /etc/openldap/certs/ldap-cert.pem
ADD pki/cacert.pem /etc/openldap/certs/cacert.pem
ADD conf/ldap.conf /etc/openldap/ldap.conf
RUN update-ca-trust force-enable
RUN update-ca-trust extact
RUN update-ca-trust check

# Add Kerberos Config in support of HDP KDC
ADD conf/krb5.conf /etc/krb5.conf
