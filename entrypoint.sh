#!/bin/sh -e

[ -d "${NEXUS_ETC}" ] || mkdir -p "${NEXUS_ETC}"

echo "new entrypoint"

for name in `ls -1 /opt/sonatype/nexus/etc`; 
do
  echo "check file $name"
  if [ -f "${NEXUS_ETC}/$name" ] 
    then 
      echo "write orig $name _orig"
      cp /opt/sonatype/nexus/etc/$name ${NEXUS_ETC}"/"$name"_orig"
    else
      echo "write initial file"
      cp /opt/sonatype/nexus/etc/$name ${NEXUS_ETC}
  fi

done;
chown -R nexus:nexus "${NEXUS_ETC}"



#cp -u -b /opt/sonatype/nexus/etc/* "${NEXUS_ETC}"


[ -d "${NEXUS_DATA}" ] || mkdir -p "${NEXUS_DATA}"
chown -R nexus:nexus "${NEXUS_DATA}"

[ -n "${JAVA_MAX_MEM}" ] && sed -i "s/-Xmx.*/-Xmx${JAVA_MAX_MEM}/g" /opt/sonatype/nexus/bin/nexus.vmoptions
[ -n "${JAVA_MIN_MEM}" ] && sed -i "s/-Xms.*/-Xmx${JAVA_MIN_MEM}/g" /opt/sonatype/nexus/bin/nexus.vmoptions
[ -n "${EXTRA_JAVA_OPTS}" ] && echo "${EXTRA_JAVA_OPTS}" >> /opt/sonatype/nexus/bin/nexus.vmoptions

[ $# -eq 0 ] && \
    exec su -s /bin/sh -c '/opt/sonatype/nexus/bin/nexus run' nexus || \
    exec "$@"
