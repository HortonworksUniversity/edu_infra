FROM jboss/keycloak:3.4.3.Final

USER root
RUN yum -y install ca-certificates openssl && yum clean all

COPY pki/postgres.crt.der /opt/jboss/postgres.crt.der

RUN sed -i 's|\(/\${env.POSTGRES_DATABASE:keycloak}\)|\1?\${env.KEYCLOAK_JDBC_PARAMS:__arg1=0}\&\${env.POSTGRES_JDBC_PARAMS:__arg2=0}|g' \
    /opt/jboss/keycloak/cli/databases/postgres/change-database.cli

RUN sed -i 's|\(/\${env.MYSQL_DATABASE:keycloak}\)|\1?\${env.KEYCLOAK_JDBC_PARAMS:__arg1=0}\&\${env.MYSQL_JDBC_PARAMS:__arg2=0}|g' \
    /opt/jboss/keycloak/cli/databases/mysql/change-database.cli
