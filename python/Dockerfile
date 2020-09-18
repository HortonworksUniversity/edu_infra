# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM wmdailey/centos-base:latest
MAINTAINER Will Dailey wdailey@cloudera.com

# Install supporting libraries for python2.7. 
# RUN rpm -Uvh http://mirror.centos.org/centos/7/os/x86_64/Packages/zlib-1.2.7-18.el7.x86_64.rpm

# The gcc compilier and python-devel are needed for Ambari Metrics
RUN yum install -y \
	bzip2-devel \
	gcc \
    	hostname \
	openssl-devel \
	python-devel \
    	sqlite-devel \
	xz-libs \
	zlib \
	zlib-devel

# Install python2.7
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz && \
    tar xvfz Python-2.7.8.tgz && \
    cd Python-2.7.8 && \
    ./configure --prefix=/usr/local && \
    make && \
    make altinstall

# Install setuptools + pip
RUN cd /tmp && \
    wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz && \
    tar -xvf setuptools-1.4.2.tar.gz && \
    cd setuptools-1.4.2 && \
    python2.7 setup.py install && \
    yum install -y python-pip && \
    yum update && yum clean all && \
    pip install virtualenv
