# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM registry.centos.org/centos:7
MAINTAINER WKD 

# Docker required set up of systemd
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# [Quote] https://hub.docker.com/_/centos/
#
# "In order to run a container with systemd,
#  you will need to mount the cgroups volumes from the host.
#  [...]
#  There have been reports that if you're using an Ubuntu host,
#  you will need to add -v /tmp/$(mktemp -d):/run
#  in addition to the cgroups mount."
#
# VOLUME [ "/sys/fs/cgroup", "/run" ]
# Install repos and update 
RUN yum install -y epel-release  
# System packages 
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
	postgresql \
	python-argparse \
	python-configobj \
	python-httplib2 \
	python-pip \
	screen \
	sudo \
	systemd* \
	tar \
	tmux \
	tzdata \
	wget \
	unzip \
	vim \
	zip 

RUN yum update -y && yum clean all

# System configure
RUN systemctl enable httpd 
RUN systemctl enable sshd 
RUN systemctl disable firewalld 
RUN chkconfig network off
ADD conf/yum.conf /etc/yum.conf 
ADD conf/config /etc/selinux/config
ADD conf/99-hadoop.conf /etc/security/limits.d/99-hadoop.conf

# Install OpenJava 
ENV JDK_ARTIFACT jdk-8u112-linux-x64.tar.gz
ENV JDK_VERSION jdk1.8.0_112
RUN mkdir -p /usr/jdk64 /usr/java\
        && cd /usr/jdk64 \
        && wget http://public-repo-1.hortonworks.com/ARTIFACTS/$JDK_ARTIFACT \
        && tar -zxvf $JDK_ARTIFACT \
        && rm -f $JDK_ARTIFACT
RUN ln -s /usr/jdk64/$JDK_VERSION /usr/java/default
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Install JCE
ADD http://public-repo-1.hortonworks.com/ARTIFACTS/jce_policy-8.zip $JAVA_HOME/jre/lib/security/
RUN cd $JAVA_HOME/jre/lib/security && unzip jce_policy-8.zip && rm -f jce_policy-8.zip && mv UnlimitedJCEPolicyJDK8/*jar . && rm -rf UnlimitedJCEPolicyJDK8

# Add common private key for general use by various apps
# This is not recommended practice
ADD pki/training-keypair.pem /etc/pki/tls/certs/training-keypair.pem

# Configure root
RUN passwd --lock root 
ADD conf/sudoers /etc/sudoers
ADD conf/bash_profile /root/.bash_profile
ADD conf/bashrc /root/.bashrc
ADD conf/skel /etc/skel
RUN mkdir /var/data

# Add local host service config file
ADD sbin/local-host-config.sh /usr/local/sbin/local-host-config.sh
ADD init/local-host.service /etc/systemd/system/local-host.service
RUN systemctl enable local-host.service
ADD init/disable-thp.service /etc/systemd/system/disable-thp.service
RUN systemctl enable disable-thp.service

# Add user sysadmin 
RUN groupadd -g 2030 admin
RUN adduser -g admin -u 1221 sysadmin \
	&& passwd --lock sysadmin \
	&& usermod -aG wheel sysadmin 

# Configure sysadmin user
ADD conf/bash_profile /home/sysadmin/.bash_profile
ADD conf/bashrc /home/sysadmin/.bashrc
RUN ln -s /var/local/bin /home/sysadmin/bin \
	&& ln -s /var/local/conf /home/sysadmin/conf \
	&& ln -s /var/data /home/sysadmin/data \
	&& ln -s /var/local/lib /home/sysadmin/lib \
	&& ln -s /var/local/sbin /home/sysadmin/sbin \
	&& ln -s /var/local/src /home/sysadmin/src

# Configure ssh
ADD conf/sshd_config /etc/ssh/
RUN mkdir /home/sysadmin/.ssh
ADD pki/id_rsa /home/sysadmin/.ssh/id_rsa
ADD pki/id_rsa.pub /home/sysadmin/.ssh/id_rsa.pub
ADD pki/training-keypair.pem /home/sysadmin/.ssh/training-keypair.pem
RUN touch /home/sysadmin/.ssh/authorized_keys \
    	&& cat /home/sysadmin/.ssh/id_rsa.pub >> /home/sysadmin/.ssh/authorized_keys \
	&& chmod 700 /home/sysadmin/.ssh/ \
	&& chmod 600 /home/sysadmin/.ssh/id_rsa.pub /home/sysadmin/.ssh/id_rsa /home/sysadmin/.ssh/authorized_keys
RUN echo "IdentityFile /home/sysadmin/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN echo "IdentityFile /home/nifi/.ssh/id_rsa" >> /etc/ssh/ssh_config

# Change ownership
RUN chmod 755 /home/sysadmin \
	&& chown -R sysadmin:admin /home/sysadmin

# Add user devuser
RUN groupadd -g 2034 dev
RUN adduser -g dev -u 1205 devuser; echo 'devuser:BadPass%1' | chpasswd
RUN usermod -aG wheel devuser

# Configure devuser user
ADD conf/bash_profile /home/devuser/.bash_profile
ADD conf/bashrc /home/devuser/.bashrc
RUN ln -s /var/local/bin /home/devuser/bin \
	&& ln -s /var/local/conf /home/devuser/conf \
	&& ln -s /var/local/data /home/devuser/data \
	&& ln -s /var/local/lib /home/devuser/lib \
	&& ln -s /var/local/sbin /home/devuser/sbin \
	&& ln -s /var/local/src /home/devuser/src

# Configure ssh
RUN mkdir /home/devuser/.ssh
ADD pki/id_rsa /home/devuser/.ssh/id_rsa
ADD pki/id_rsa.pub /home/devuser/.ssh/id_rsa.pub
RUN touch /home/devuser/.ssh/authorized_keys \
    	&& cat /home/devuser/.ssh/id_rsa.pub >> /home/devuser/.ssh/authorized_keys \
	&& chmod 700 /home/devuser/.ssh/ \
	&& chmod 600 /home/devuser/.ssh/id_rsa.pub /home/devuser/.ssh/id_rsa /home/devuser/.ssh/authorized_keys
RUN echo "IdentityFile /home/devuser/.ssh/id_rsa" >> /etc/ssh/ssh_config

# Change ownership
RUN chmod 755 /home/devuser \
	&& chown -R devuser:dev /home/devuser

# Set Env
ENV PS1 "[\u@\h \W]# "

EXPOSE 22 

CMD ["/usr/sbin/init"]
