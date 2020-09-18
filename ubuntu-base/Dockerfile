# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM ubuntu:20.04
MAINTAINER Will Dailey wdailey@cloudera.com 

# Docker required set up of systemd
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

# Install support packages
RUN apt update && \
    apt-get install -y --no-install-recommends -yqq \
        apache2 \
        apt-utils \
        ca-certificates \
        curl \
	dnsutils \
        epiphany-browser \
        gedit \
        gedit-plugins \
        gedit-common \
        gettext \
	iputils-ping \
        mc \
        net-tools \
	openssh-client \
        sudo \
	tar \
        ttf-wqy-zenhei \
        tzdata \
        vim \
	unzip \
        wget \
        wmctrl \
	zip && \
        apt-get clean -y

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Fix sh
RUN rm /bin/sh \
	&& ln -s /bin/bash /bin/sh

# Generate locales for en_US.UTF-8
RUN apt-get update && \
	apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales \
    	&& update-locale LANG=en_US.UTF-8
ENV LANGUAGE='en_US:en' \
    LANG='en_US.UTF-8' \
    LC_ALL='en_US.UTF-8'

# Install JDK 8
RUN  apt-get update && \
        apt-get install -y default-jdk && \
        apt-get clean -y

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/default-java

# Configure root
RUN passwd --lock root
ADD conf/bash_profile /root/.bash_profile
ADD conf/bashrc /root/.bashrc
RUN mkdir /var/data

# Add resolv.conf file to be copied over after start up
ADD conf/resolv.conf /etc/resolv.conf.override

# Add local host service config
ADD sbin/local-host-config.sh /usr/local/sbin/local-host-config.sh
ADD init/local-host.service /etc/systemd/system/local-host.service
RUN systemctl enable local-host.service

# Create admin user ubuntu
RUN adduser --disabled-password --gecos "" ubuntu && \
	usermod -aG sudo ubuntu

# Configure ubuntu user
ADD conf/bash_profile /home/ubuntu/.bash_profile
ADD conf/bashrc /home/ubuntu/.bashrc

# Configure ssh
ADD conf/sshd_config /etc/ssh/
RUN mkdir /home/ubuntu/.ssh
ADD pki/id_rsa /home/ubuntu/.ssh/id_rsa
ADD pki/id_rsa.pub /home/ubuntu/.ssh/id_rsa.pub
RUN touch /home/ubuntu/.ssh/authorized_keys \
    	&& cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys \
    	&& chmod 700 /home/ubuntu/.ssh/ \
    	&& chmod 600 /home/ubuntu/.ssh/id_rsa.pub /home/ubuntu/.ssh/id_rsa /home/ubuntu/.ssh/authorized_keys

# Change ownership and permissions
RUN chown -R ubuntu:ubuntu /home/ubuntu \
	&& chmod 755 /home/ubuntu

# Add user devuser
RUN addgroup dev
RUN useradd --group dev --shell /bin/bash devuser \
	&& echo "devuser:BadPass%1" | chpasswd \
	&& usermod -aG sudo devuser

# Configure devuser user
ADD conf/bash_profile /home/devuser/.bash_profile
ADD conf/bashrc /home/devuser/.bashrc
RUN ln -s /var/local/bin /home/devuser/bin \
        && ln -s /var/local/conf /home/devuser/conf \
        && ln -s /var/data /home/devuser/data \
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

# Change ownership
RUN chmod 755 /home/devuser \
	&& chown -R devuser:devuser /home/devuser

# Set Env
ENV PS1 "[\u@\h \W]# "

# Command
CMD ["/sbin/init"]
