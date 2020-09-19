# Clone from the CentOS 7
#FROM registry.centos.org/centos:7
FROM wmdailey/security:latest
MAINTAINER WKD

LABEL summary="Identity Management (IdM) for Linux provides centralized \
management of identities and policies for Atomic Host"
LABEL description="IPA is an integrated solution to provide centrally managed \
Identity (users, hosts, services), Authentication (SSO, 2FA), and \
Authorization (host access control, SELinux user roles, services). The \
solution provides features for further integration with Linux based clients \
(SUDO, automount) and integration with Active Directory based infrastructures \
(Trusts)."


# Moving groupadd before freeipa installation to ensure uid and guid will be same
RUN groupadd -g 288 kdcproxy ; useradd -u 288 -g 288 -c 'IPA KDC Proxy User' -d '/var/lib/kdcproxy' -s '/sbin/nologin' kdcproxy
RUN groupadd -g 289 ipaapi; useradd -u 289 -g 289 -c 'IPA Framework User' -r -d / -s '/sbin/nologin' ipaapi

# Workaround 1615948
RUN ln -s /bin/false /usr/sbin/systemd-machine-id-setup

# IPv6 stack is enabled in the kernel but no interface
RUN echo "net.ipv6.conf.lo.disable_ipv6 = 0" > /etc/sysctl.conf

# Install software
RUN yum upgrade -y && yum install -y ipa-server ipa-server-dns ipa-server-trust-ad patch && yum clean all

# Container image which runs systemd
ENV container oci

# Establish reasonably low open files limit in the container
RUN echo "DefaultLimitNOFILE=1024" >> /etc/systemd/system.conf

STOPSIGNAL RTMIN+3

# Minimize the systemd setup
RUN find /etc/systemd/system /usr/lib/systemd/system/{basic,multi-user,sysinit}.target.wants -type l \! -lname /dev/null | xargs rm -v

# Required patches
COPY patches/minimal-centos-7.patch /root/
RUN patch --verbose -p0 --fuzz=0 < /root/minimal-centos-7.patch

# Systemd control
COPY init/container-ipa.target /usr/lib/systemd/system/
RUN systemctl set-default container-ipa.target
RUN rmdir -v /etc/systemd/system/multi-user.target.wants \
	&& mkdir /etc/systemd/system/container-ipa.target.wants \
	&& ln -s /etc/systemd/system/container-ipa.target.wants /etc/systemd/system/multi-user.target.wants
RUN rm /var/lib/systemd/random-seed
RUN echo 0123456789abcdef0000000000000000 > /etc/machine-id && systemd-tmpfiles --remove --create && echo -n > /etc/machine-id

# Prepare for basic ipa-server-install in container
# Address failing rhel-domainname.service in the ipa-client-install step
RUN mv /usr/bin/domainname /usr/bin/domainname.orig
ADD sbin/hostnamectl-wrapper /usr/bin/domainname

# Required patches
COPY patches/ipa-rhel-7.patch /root
RUN set -o pipefail ; patch --verbose -p0 --fuzz=0 < /root/ipa-rhel-7.patch | tee /dev/stderr | sed -n 's/^patching file //;T;/\.py$/p' | xargs python -m compileall

# Move configuration and data to data volume
COPY patches/ipa-data-centos-7.patch /root
RUN set -o pipefail ; patch --verbose -p0 --fuzz=0 < /root/ipa-data-centos-7.patch | tee /dev/stderr | sed -n 's/^patching file //;T;/\.py$/p' | xargs python -m compileall

RUN mv /usr/sbin/ipa-join /usr/sbin/ipa-join.orig
COPY sbin/ipa-join /usr/sbin/ipa-join

COPY utils/prepare-volume-template utils/populate-volume-from-template utils/extract-rpm-upgrade-scriptlets /usr/local/bin/
COPY conf/volume-data-list conf/volume-tmp-list conf/volume-data-autoupdate /etc/
RUN /usr/local/bin/prepare-volume-template /etc/volume-data-list /data
RUN /usr/local/bin/prepare-volume-template /etc/volume-tmp-list /tmp
RUN /usr/local/bin/extract-rpm-upgrade-scriptlets
RUN echo 2.0 > /etc/volume-version
COPY init/init-data-minimal /usr/local/sbin/init

# Configure master/replica upon the first invocation
COPY init/init-data /usr/local/sbin/init
COPY sbin/ipa-server-configure-first sbin/exit-with-status sbin/ipa-volume-upgrade-* /usr/sbin/
COPY init/ipa-server-configure-first.service init/ipa-server-upgrade.service init/ipa-server-update-self-ip-address.service /usr/lib/systemd/system/
RUN ln -sv /usr/lib/systemd/system/ipa-server-configure-first.service /data-template/etc/systemd/system/container-ipa.target.wants/ipa-server-configure-first.service
COPY conf/exit-via-chroot.conf /usr/lib/systemd/system/systemd-poweroff.service.d/

VOLUME [ "/tmp", "/run", "/data", "/var/log/journal" ]

EXPOSE 53/udp 53 80 443 389 636 88 464 88/udp 464/udp 123/udp

RUN uuidgen > /data-template/build-id
