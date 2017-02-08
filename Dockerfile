FROM       java:8-jre-alpine
MAINTAINER Stephan Spindler <spind42@gmail.com>

ENV NEXUS_DATA /nexus-data
ENV NEXUS_VERSION 3.2.0-01
ENV NEXUS_ETC /nexus-etc


# install openssl
RUN apk update && apk add openssl && rm -fr /var/cache/apk/*
  

RUN mkdir -p /opt/sonatype/ \
  && wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz -O - \
  | tar zx -C /opt/sonatype/ \
  && mv /opt/sonatype/nexus-${NEXUS_VERSION} /opt/sonatype/nexus

## configure nexus runtime env #/opt/sonatype/nexus/etc|
RUN sed \
    -e "s|karaf.home=.|karaf.home=/opt/sonatype/nexus|g" \
    -e "s|karaf.base=.|karaf.base=/opt/sonatype/nexus|g" \
#    -e "s|karaf.etc=etc|karaf.etc=${NEXUS_ETC}|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=${NEXUS_ETC}|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i /opt/sonatype/nexus/bin/nexus.vmoptions

## create nexus user
RUN echo "nexus:x:200:200:nexus role account:${NEXUS_DATA}:/bin/false" >> /etc/passwd
RUN echo "nexus:x:200:" >> /etc/group
RUN echo "nexus:!::0:::::" >> /etc/shadow

## prevent warning: /opt/sonatype/nexus/etc/org.apache.karaf.command.acl.config.cfg (Permission denied)
RUN chown nexus:nexus /opt/sonatype
#RUN chown nexus:nexus /opt/sonatype/nexus/etc/

COPY entrypoint.sh /

VOLUME ${NEXUS_DATA}

VOLUME ${NEXUS_ETC}

EXPOSE 8081
WORKDIR /opt/sonatype/nexus
#USER nexus

ENV JAVA_MIN_MEM 1200m
ENV EXTRA_JAVA_OPTS ""

ENTRYPOINT ["/entrypoint.sh"]
