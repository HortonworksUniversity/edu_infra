FROM wmdailey/security:latest
MAINTAINER WKD

ENV KEYCLOAK_VERSION 11.0.2
ARG KEYCLOAK_DIST=https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz
ENV KEYCLOAKPASS BadPass%1

# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false

USER root

# Supporting packages
#RUN yum install -y java-1.8.0-openjdk-devel

# Download and install software
WORKDIR /opt
RUN wget $KEYCLOAK_DIST && \
tar xzf keycloak-$KEYCLOAK_VERSION.tar.gz && \
rm keycloak-$KEYCLOAK_VERSION.tar.gz && \
chmod 755 /opt/keycloak-$KEYCLOAK_VERSION && \
ln -s keycloak-$KEYCLOAK_VERSION keycloak 

# Systemd
#ADD init/keycloak.service /etc/systemd/system/keycloak.service 
#RUN systemctl enable keycloak
    
# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r keycloak && \
useradd -r -g keycloak -m -d /var/lib/keycloak -s /sbin/nologin -c "keycloak user" keycloak && \
chown -R keycloak:keycloak /opt/keycloak-$KEYCLOAK_VERSION && \
chmod 700 /opt/keycloak-$KEYCLOAK_VERSION/standalone

# Set the working directory to jboss' user home directory
USER keycloak

RUN /opt/keycloak/bin/add-user-keycloak.sh --realm master --user admin --password $KEYCLOAKPASS 

ADD cli /opt/keycloak/cli
RUN cd /opt/keycloak && bin/jboss-cli.sh --file=cli/standalone-configuration.cli && rm -rf /opt/keycloak/standalone/configuration/standalone_xml_history
RUN cd /opt/keycloak && bin/jboss-cli.sh --file=cli/standalone-ha-configuration.cli && rm -rf /opt/keycloak/standalone/configuration/standalone_xml_history

# Connect to RDBMS PostgreSQL
#ENV JDBC_POSTGRES_VERSION 42.2.2
#ADD databases/change-database.sh /opt/keycloak/bin/change-database.sh

#RUN mkdir -p /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; cd /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; curl -L http://central.maven.org/maven2/org/postgresql/postgresql/$JDBC_POSTGRES_VERSION/postgresql-$JDBC_POSTGRES_VERSION.jar > postgres-jdbc.jar
#ADD databases/postgres/module.xml /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main

ENV JBOSS_HOME /opt/keycloak
ENV LANG en_US.UTF-8

EXPOSE 8080 8443 9990 9993

ADD sbin/docker-entrypoint.sh /opt/keycloak/
ENTRYPOINT [ "/opt/keycloak/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
