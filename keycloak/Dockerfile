FROM wmdailey/security:latest
MAINTAINER WKD

ENV KEYCLOAK_VERSION 11.0.2
ARG KEYCLOAK_DIST=https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz
ARG KEYCLOAK_ADMIN 
ARG KEYCLOAK_PASSWORD 

# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV KEYCLOAK_HOME=/opt/keycloak
ENV LANG en_US.UTF-8

USER root

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

ADD cli /opt/keycloak/cli

# Connect to RDBMS PostgreSQL
#ADD databases/change-database.sh /opt/keycloak/bin/change-database.sh
#RUN mkdir -p /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; cd /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main; curl -L http://central.maven.org/maven2/org/postgresql/postgresql/$JDBC_POSTGRES_VERSION/postgresql-$JDBC_POSTGRES_VERSION.jar > postgres-jdbc.jar
#ADD databases/postgres/module.xml /opt/keycloak/modules/system/layers/base/org/postgresql/jdbc/main
    
ADD sbin/docker-entrypoint.sh /opt/keycloak/

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

RUN /opt/keycloak/bin/add-user-keycloak.sh --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_PASSWORD

RUN cd /opt/keycloak && bin/jboss-cli.sh --file=cli/standalone-configuration.cli && rm -rf /opt/keycloak/standalone/configuration/standalone_xml_history
RUN cd /opt/keycloak && bin/jboss-cli.sh --file=cli/standalone-ha-configuration.cli && rm -rf /opt/keycloak/standalone/configuration/standalone_xml_history

EXPOSE 8080 8443

ENTRYPOINT [ "/opt/keycloak/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
