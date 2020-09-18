# This Dockerfile is for educational purposes. The author assumes # no liability for use outside of a training environment.
# This file is subject to change without notification and it
# is not supported. Unless required by applicable law or agreed
# to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied.

# The original code came from github.com RattyDAVE / docker-ubuntu-xrdp-mate-custom

FROM wmdailey/ubuntu-base
MAINTAINER Will Dailey wdailey@cloudera.com

LABEL io.description="NoVNC Container with Mate window manager and Chrome build on Ubuntu 20.04" \
      io.display-name="NoVNC Container"

# VARIABLES 
# Environment config
ENV NOVNC_DIR=/opt/novnc \
    DEBIAN_FRONTEND=noninteractive \
    term=xterm

# Connection ports for controlling the UI:
ENV DISPLAY=:0 \
    REDIRECT_PORT=6080 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 

EXPOSE ${REDIRECT_PORT} ${VNC_PORT} ${NO_VNC_PORT} 3389 22

# Install lib packages for Mate and X11
RUN apt update && \
    apt-get install -y \
	apache2 \
	autoconf \
  	build-essential \
        bison \
	flex \
	fuse \
	gettext \
	git \
        libfdk-aac-dev \
        libfuse-dev \
        libjpeg-dev \
        libmp3lame-dev \
        libpam0g-dev \
        libssl-dev \
        libopus-dev \
 	libpam0g-dev \
	libpam-kwallet4 \
	libpam-kwallet5 \
	libtool \
   	libssl-dev \
        libx11-dev \
        libxfont-dev \
        libxml-parser-perl \
        libxrandr-dev \
        libxfixes-dev \
	lightdm \
	nasm \
        pkg-config \
        python-libxml2 \
	python-numpy \
        software-properties-common \
	supervisor \
        tightvncserver \
    	x11vnc \
        xsltproc \
        xserver-xorg-core \
        xserver-xorg-dev \
        xterm \
        xubuntu-default-settings \
	xvfb && \
     apt-get remove -y gdm3 && \
     apt-get clean -y
	
# Ubuntu MATE is a free and open-source Linux distribution and an 
# official derivative of Ubuntu.It uses the MATE desktop environment 
# as its default user interface, instead of the GNOME 3 desktop 
# environment that is the default user interface for Ubuntu. 
# Install Mate packages
RUN cd /root && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    sed -i 's/^#\s*\(deb.*restricted\)$/\1/g' /etc/apt/sources.list && \ 
    apt-get update -y && \ 
    apt-get install -yqq \
        mate-desktop-environment-core \
        mate-themes \
        mate-accessibility-profiles \
        mate-applet-appmenu \
        mate-applet-brisk-menu \
        mate-applets \
        mate-applets-common \
        mate-calc \
        mate-calc-common \
        mate-dock-applet \
        mate-hud \
        mate-indicator-applet \
        mate-indicator-applet-common \
        mate-menu \
        mate-notification-daemon \
        mate-notification-daemon-common \
        mate-utils \
        mate-utils-common \
        mate-window-applets-common \
        mate-window-buttons-applet \
        mate-window-menu-applet \
        mate-window-title-applet \
        ubuntu-mate-icon-themes \
        ubuntu-mate-themes && \
     apt-get clean -y

# Configure Apache2
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY pki/hdplabs /etc/ssl/hdplabs
COPY conf/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/00-noVNC.conf /etc/apache2/sites-enabled/00-noVNC.conf
RUN rm -f /etc/apache2/mods-enabled/autoindex.conf /etc/apache2/mods-enabled/ssl.conf 
RUN a2enmod proxy.load rewrite.load cache.load proxy_http.load ssl.load proxy_wstunnel.load \
        && a2dissite 000-default.conf

# Configure lightdm
COPY conf/default-display-manager /etc/X11/default-display-manager
COPY conf/lightdm.conf /etc/lightdm/lightdm.conf
COPY conf/01-autologin.conf /etc/lightdm/lightdm.conf.d/01-autologin.conf

# Add wallpaper
COPY images/cloudera_*.jpg /usr/share/backgrounds/

# Configure randr
COPY sbin/randr.sh /usr/local/bin/randr.sh
RUN chmod 755 /usr/local/bin/randr.sh

# Install noVNC files - HTML5 based VNC viewer
RUN mkdir -p ${NOVNC_DIR}
COPY novnc/ ${NOVNC_DIR}/
COPY sbin ${NOVNC_DIR}/sbin

# Configure x11vnc
RUN ln -s ${NOVNC_DIR}/vnc.html ${NOVNC_DIR}/index.html && \
    ln -s /usr/bin/python2.7 /usr/bin/python
COPY conf/xserverrc /etc/X11/xinit/xserverrc
RUN chmod 755 /etc/X11/xinit/xserverrc

# Configure password for noVNC user
COPY sbin/rc.local /etc/rc.local
RUN chmod +x /etc/rc.local 

# Configure for devuser sessions
COPY conf/skel.config /home/devuser/.config
COPY conf/xsessionrc.desktop /home/devuser/.config/autostart/.xsessionrc.desktop
RUN chown devuser:dev /home/devuser/.config/autostart/.xsessionrc.desktop
COPY conf/xsessionrc /home/devuser/.xsessionrc
RUN chmod ug+x /home/devuser/.xsessionrc && \
    chown devuser:dev /home/devuser/.xsessionrc
COPY conf/Desktop/ /home/devuser/Desktop/

# Configure Change Resolution
RUN chown devuser:devuser /home/devuser/Desktop/Change_Resolution.desktop && \
    chmod 755 /home/devuser/Desktop/Change_Resolution.desktop

# Configure for auto startup
COPY init/display-manager.service /etc/systemd/system/display-manager.service
COPY init/x11vnc.service /etc/systemd/system/x11vnc.service
COPY init/websockify.service /etc/systemd/system/websockify.service
#RUN systemctl enable lightdm.service && \
RUN systemctl enable apache2.service && \
    systemctl enable websockify.service &&\
    systemctl enable x11vnc.service 

# Install Chromium browser
#RUN apt-get update \
#       && apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg \
#       && apt-get clean -y
#RUN echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > ${NOVNC_DIR}/.chromium-browser.init

# Install Chrome browser
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN     apt-get update \
        && apt-get install -y --allow-unauthenticated google-chrome-stable

# Cleanup
RUN apt-get -y purge \
        autoconf \
        bison \
        build-essential \
        flex \
        gettext \
        git \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev \
        libxfont-dev \
        libx11-dev \
        libxfixes-dev \
        libxrandr-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        libxml-parser-perl \
        libfuse-dev \
        nasm \
        pkg-config \
        python-libxml2 \
        xserver-xorg-dev \
        xsltproc && \
	apt-get clean -y
