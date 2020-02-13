FROM jboss/base-jdk:8

ENV JBOSS_EAP_VERSION 6.2.1
ENV JBOSS_HOME /opt/jboss/jboss-full
ENV JBOSS_EXTRACT_FOLDER jboss-full
ENV PATH="${PATH}:${HOME}/bin:${JBOSS_HOME}/bin"

# User root user to install software
USER root

COPY jboss-fuse-6.2.1 /opt/jboss/jboss-full
WORKDIR $JBOSS_HOME

ENV LAUNCH_JBOSS_IN_BACKGROUND true

#newrelic

RUN mkdir /opt/jboss/jboss-full/newrelic
COPY newrelic /opt/jboss/jboss-full/newrelic

##maven

COPY maven/apache-maven-3.6.3 /opt/maven
ENV PATH=$PATH:/opt/maven/bin


COPY org.ops4j.pax.url.mvn.cfg /opt/jboss/jboss-full/etc/org.ops4j.pax.url.mvn.cfg

COPY pom.xml /opt/jboss/jboss-full/deploy/
RUN mvn install -f /opt/jboss/jboss-full/deploy/pom.xml

COPY smg-esb-features-mobile-1.0.0-ALPHA.5.jar /opt/jboss/jboss-full/deploy/
COPY sqljdbc41.jar /opt/jboss/jboss-full/deploy/
COPY jconn3-6.0.26312.jar /opt/jboss/jboss-full/deploy/
WORKDIR /opt/jboss/jboss-full/deploy
RUN mvn install -f pom.xml
RUN mvn install:install-file -Dfile=sqljdbc41.jar -Dpackaging=jar -DgroupId=com.microsoft.sqlserver -DartifactId=sqljdbc4 -Dversion=4.0
RUN mvn install:install-file -Dfile=jconn3-6.0.26312.jar -Dpackaging=jar -DgroupId=com.sybase -DartifactId=jconn3 -Dversion=6.0.26312
RUN mvn install:install-file -Dfile=smg-esb-features-mobile-1.0.0-ALPHA.5.jar -Dpackaging=jar -DgroupId=smg.esb.features.mobile -DartifactId=smg-esb-features-mobile -Dversion=4.0


RUN chmod -R 777 /opt
WORKDIR /opt/jboss/jboss-full

RUN /opt/jboss/jboss-full/bin/karaf & \
sleep 60 && \ 
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install jndi/1.0.0 && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install camel-mybatis && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install camel-quartz2 && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install camel-script-javascript && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install camel-velocity/2.15.1.redhat-621084 && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install camel-jackson/2.15.1.redhat-621084 && \
/opt/jboss/jboss-full/bin/client -u admin -p admin features:install cxf-rs-security-cors/3.0.4.redhat-621084 && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s wrap:mvn:com.microsoft.sqlserver/sqljdbc4/4.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s wrap:mvn:com.sybase/jconn3/6.0.26312' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.atomikos/transactions-api/3.9.3' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.atomikos/transactions-jdbc/3.9.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.atomikos/transactions-jta/3.9.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.atomikos/atomikos-util/3.9.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.atomikos/transactions-osgi/3.9.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:commons-dbcp/commons-dbcp/1.4' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-jdbc/2.5.5' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.mybatis/mybatis-spring/1.2.2' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.google.guava/guava/19.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:commons-digester/commons-digester/1.8.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:commons-validator/commons-validator/1.5.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.google.code.gson/gson/2.3' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.googlecode.json-simple/json-simple/1.1.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.json/json/20160810' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.threeten/threetenbp/1.3.3' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.doctusoft/json-schema-java7/1.4.1.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:commons-beanutils/commons-beanutils/1.9.4' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.codehaus.jackson/jackson-core-asl/1.9.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.codehaus.jackson/jackson-mapper-asl/1.9.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.codehaus.jackson/jackson-jaxrs/1.9.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:bundle-level --force fuse-bundle-ds-sybase-prestaci 50' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:bundle-level --force fuse-bundle-ds-sybase-gps-smg 50' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.apache.httpcomponents/httpcore-osgi/4.3.3' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.apache.httpcomponents/httpclient-osgi/4.3.6' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-core/3.0.2.RELEASE' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-aop/3.0.2.RELEASE' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-beans/3.0.2.RELEASE' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-context/3.0.2.RELEASE' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.springframework/spring-web/3.0.2.RELEASE' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.apache.camel/camel-http4/2.15.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:org.apache.camel/camel-core/2.15.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:net.minidev/asm/1.0.2' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:net.minidev/json-smart/2.1.1' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'osgi:install -s mvn:com.jayway.jsonpath/json-path/1.2.0' && \
/opt/jboss/jboss-full/bin/client -u admin -p admin 'shutdown -f' && \
sleep 10



## bundles para granja de seguridad
COPY api-manager/* /opt/jboss/jboss-full/deploy/



ENV EXTRA_JAVA_OPTS="-javaagent:/opt/jboss/jboss-full/newrelic/newrelic.jar"

RUN yum install -y svn
RUN yum install -y telnet
RUN chmod -R 777 /opt/jboss/jboss-full/*
RUN rm /opt/jboss/jboss-full/data/log/*

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614 18181

###
CMD ["/opt/jboss/jboss-full/bin/fuse", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
