FROM centos:7

ARG USE_PROXY
ARG PROXY_HOST
ARG PROXY_PORT
ARG MAVEN_VERSION
ARG DOCKER_VERSION
ARG DOCKER_COMPOSE_VERSION

RUN if "$USE_PROXY" = true; then echo proxy=$PROXY_HOST:$PROXY_PORT | tee -a /etc/yum.conf; fi

#########################  JDK  #########################
RUN if "$USE_PROXY" = true; then rpm --httpproxy $PROXY_HOST --httpport $PROXY_PORT --import http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems; else rpm --import http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems; fi
RUN if "$USE_PROXY" = true; then curl -x $PROXY_HOST:$PROXY_PORT -o /etc/yum.repos.d/zulu.repo http://repos.azulsystems.com/rhel/zulu.repo; else curl -o /etc/yum.repos.d/zulu.repo http://repos.azulsystems.com/rhel/zulu.repo; fi

RUN yum -y update
RUN yum -y install zulu-8

ENV JAVA_HOME /usr/lib/jvm/zulu-8/
ENV PATH $JAVA_HOME/bin:$PATH

#########################  GIT  #########################
RUN yum update -y
RUN yum install -y git
RUN if "$USE_PROXY" = true; then git config --global http.proxy $PROXY_HOST:$PROXY_PORT; fi

#########################  MAVEN  #########################
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && if "$USE_PROXY" = true; then curl -x $PROXY_HOST:$PROXY_PORT -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz; \
     else curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz; fi \
    | tar -xzC /usr/share/maven --strip-components=1 \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG /root/.m2
ENV PATH $MAVEN_HOME/bin:$PATH

RUN mkdir -p /root/.m2
ADD settings.xml /root/.m2

#########################  UTILS  #########################
RUN yum install -y dos2unix

#########################  DOCKER  #########################
RUN if "$USE_PROXY" = true; then curl -x $PROXY_HOST:$PROXY_PORT -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz; else curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz; fi
RUN tar -xvzf docker-$DOCKER_VERSION.tgz -C /etc
RUN mv /etc/docker/* /usr/bin/

# Then start docker in daemon mode:
RUN dockerd &

#########################  DOCKER COMPOSE  #########################
RUN if "$USE_PROXY" = true; then curl -x $PROXY_HOST:$PROXY_PORT -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose; else curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose; fi
RUN chmod +x /usr/local/bin/docker-compose



##################################################
RUN yum clean all

RUN mkdir -p /usr/src/build
COPY build.sh /usr/src/build/build.sh
RUN dos2unix /usr/src/build/build.sh

RUN mkdir -p /usr/src/app
RUN mkdir -p /usr/src/jacoco

RUN chmod 755 /tmp

ENTRYPOINT ["/usr/src/build/build.sh"]
