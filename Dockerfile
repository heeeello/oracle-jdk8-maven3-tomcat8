FROM ubuntu:14.04

MAINTAINER jim.mei@centling.com

ENV TOMCAT_VERSION 8.0.38

# Set locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
apt-get install -y git build-essential curl wget software-properties-common

# Install JDK 8
RUN \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
apt-get install -y oracle-java8-installer wget unzip tar && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz && \
    echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c  && \
    tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/  && \
    ln -s /opt/apache-maven-3.2.2 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin && \
    rm -f /tmp/apache-maven-3.2.2.tar.gz

ENV MAVEN_HOME /opt/maven

# Get Tomcat
RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
    tar xzvf /tmp/tomcat.tgz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm /tmp/tomcat.tgz && \
    rm -rf /opt/tomcat/webapps/examples && \
    rm -rf /opt/tomcat/webapps/docs && \
    rm -rf /opt/tomcat/webapps/ROOT

# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

EXPOSE 8080
EXPOSE 8009

WORKDIR /opt/tomcat

# Launch Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
