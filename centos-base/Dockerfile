# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM registry.centos.org/centos:7

# Labels
LABEL maintainer="William Dailey <wdailey@cloudera.com>"
LABEL org.label-schema.description="Centos 7 base image to support applications"
LABEL org.label-schema.version="Centos 7.8 Base"

# Environmental variables
ENV container docker

# Set up to install systemd. While this is not required for all
# containers it is required for FreeIPA and others.
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

#  There have been reports that if you're using an Ubuntu host,
#  you will need to add -v /tmp/$(mktemp -d):/run
#  in addition to the cgroups mount."
#
# VOLUME [ "/sys/fs/cgroup", "/run" ]

# Install repo  
RUN yum install -y epel-release  

# Install system packages 
RUN yum install -y \
	ack \
	bzip2 \
	chrony \
	curl \
	deltarpm \
	emacs \
	gedit \
	git \
	httpd \
	file \
	firewalld \
	initscripts \
	net-tools \
	nss \
	psmisc \
	mosh \
	nano \
	openssl \
	openssh-server \
	openssh-clients \
	python-argparse \
	python-configobj \
	python-httplib2 \
	screen \
	sudo \
	systemd* \
	tar \
	tmux \
	tzdata \
	wget \
	unzip \
	vim \
	zip \ 
	yum update -y && yum clean all

# Configure systemd, yum, ssh, and locale
ADD init/disable-thp.service /etc/systemd/system/disable-thp.service
RUN systemctl enable httpd && \
	systemctl enable sshd && \
	systemctl disable firewalld  && \
	systemctl enable disable-thp.service && \
	chkconfig network off
ADD conf/yum.conf /etc/yum.conf 
ADD conf/config /etc/selinux/config
ADD conf/sshd_config /etc/ssh/
ADD conf/99-hadoop.conf /etc/security/limits.d/99-hadoop.conf
RUN localedef --no-archive -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8

# Install OpenJava jre and jdk 
RUN yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
	yum update -y && yum clean all
RUN mkdir /usr/java && ln -s /usr/lib/jvm/java /usr/java/default
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Install PostgreSQL 10
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm  && \
	yum install -y postgresql10 && \
        yum update -y && yum clean all

# Install PostgreSQL JDBC
RUN mkdir -p /usr/share/java
ADD https://jdbc.postgresql.org/download/postgresql-42.2.12.jar /usr/share/java/postgresql-42.2.12.jar
RUN ln -s /usr/share/java/postgresql-42.2.12.jar /usr/share/java/postgresql-jdbc.jar 

# Configure user root 
RUN passwd --lock root 
ADD conf/sudoers /etc/sudoers
ADD conf/bash_profile /root/.bash_profile
ADD conf/bashrc /root/.bashrc
ADD conf/skel /etc/skel

# Configure user sysadmin 
RUN groupadd -g 2030 admin && \
	adduser -g admin -u 1221 sysadmin && \
	passwd --lock sysadmin && \
	usermod -aG wheel sysadmin 
ADD conf/bash_profile /home/sysadmin/.bash_profile
ADD conf/bashrc /home/sysadmin/.bashrc

# Configure user sysadmin ssh directory
RUN mkdir /home/sysadmin/.ssh
ADD pki/id_rsa /home/sysadmin/.ssh/id_rsa
ADD pki/id_rsa.pub /home/sysadmin/.ssh/id_rsa.pub
RUN echo "IdentityFile /home/sysadmin/.ssh/id_rsa" >> /etc/ssh/ssh_config && \
	touch /home/sysadmin/.ssh/authorized_keys && \
    	cat /home/sysadmin/.ssh/id_rsa.pub >> /home/sysadmin/.ssh/authorized_keys && \
	chmod 700 /home/sysadmin/.ssh/ && \
	chmod 600 /home/sysadmin/.ssh/id_rsa.pub /home/sysadmin/.ssh/id_rsa /home/sysadmin/.ssh/authorized_keys && \
	chown -R sysadmin:admin /home/sysadmin

# Expose ssh port 22
EXPOSE 22 

# Start docker command
CMD ["/usr/sbin/init"]
