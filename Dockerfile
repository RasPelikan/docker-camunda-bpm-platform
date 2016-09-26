FROM ubuntu:latest

ENV VERSION 7.5.4-ee
ENV GROUP wildfly
ENV DISTRO wildfly10
ENV SERVER wildfly-10.0.0.Final
ENV PREPEND_JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0
ENV LAUNCH_JBOSS_IN_BACKGROUND TRUE
ENV LANG en_US.UTF-8
ENV ENTERPRISE_DOWNLOAD https://camunda.org/enterprise-release/camunda-bpm/wildfly10/7.5/7.5.4/camunda-bpm-ee
ARG ENTERPRISE_USER
ARG ENTERPRISE_PASSWORD

WORKDIR /opt/jboss/wildfly

# generate locale
RUN locale-gen en_US.UTF-8

# install oracle java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/oracle-jdk.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && \
    apt-get -y install --no-install-recommends oracle-java8-installer xmlstarlet ca-certificates && \
    apt-get clean && \
    rm -rf /var/cache/* /var/lib/apt/lists/*

# add camunda distro
RUN wget --user ${ENTERPRISE_USER} --password ${ENTERPRISE_PASSWORD} -O - "${ENTERPRISE_DOWNLOAD}-${DISTRO}-${VERSION}.tar.gz" | \
    tar xzf - -C /opt/jboss/wildfly/ server/${SERVER} --strip 2
RUN rm -fR /opt/jboss/wildfly/standalone/deployments/camunda-welcome.war*
RUN rm -fR /opt/jboss/wildfly/standalone/deployments/camunda-h2-webapp-7.5.4-ee.war
RUN rm -fR /opt/jboss/wildfly/standalone/deployments/camunda-example*

# add scripts
ADD bin/* /usr/local/bin/

EXPOSE 8080

CMD ["/usr/local/bin/configure-and-run.sh"]
