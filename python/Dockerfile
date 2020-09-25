# This Dockerfile is for educational purposes. The author assumes
# no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

FROM wmdailey/centos-base:latest

# Labels
LABEL maintainer="William Dailey <wdailey@cloudera.com>"
LABEL org.label-schema.description="Centos 7 image with python 3"
LABEL org.label-schema.version="Centos 7 Python 3.6"

# Variables
ENV PYTHON_VER=3.7.9

# Install Developer packages
# The gcc compilier and python-devel are required to install python 
# openldap-devel required for pyldap
RUN yum install -y \
	bzip2-devel \
	gcc \
    	hostname \
	libffi-devel \
	openldap-devel \
	openssl-devel \
	python-devel \
    	sqlite-devel \
	which \
	xz-libs \
	zlib \
	zlib-devel

# Install python
RUN cd /usr/src && \
	wget https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz && \
	tar xvfz Python-$PYTHON_VER.tgz && \
	cd Python-$PYTHON_VER && \
	./configure --prefix=/usr/local --enable-optimizations && \
	make altinstall
RUN rm /usr/src/Python-$PYTHON_VER.tgz && \
	/usr/local/bin/python3.7 -m pip install --upgrade pip
