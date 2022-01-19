FROM registry.access.redhat.com/ubi8/ubi:8.0

MAINTAINER Red Hat Training <training@redhat.com>

LABEL Component="httpd" \
 Name="s2i-do288-httpd" \
 Version="1.0" \
 Release="1"
# Labels consumed by OpenShift
LABEL io.k8s.description="A basic Apache HTTP Server S2I builder image" \
 io.k8s.display-name="Apache HTTP Server S2I builder image for DO288" \
 io.openshift.expose-services="8080:http" \
 io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" 

# DocumentRoot for Apache
ENV DOCROOT=/var/www/html 


RUN   yum install -y --nodocs --disableplugin=subscription-manager httpd && \
      yum clean all --disableplugin=subscription-manager -y && \
      echo "Hello from the httpd-parent container!" > ${DOCROOT}/index.html

# Allows child images to inject their own content into DocumentRoot
ONBUILD COPY src/ ${DOCROOT}/

EXPOSE 8080

RUN sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf

# This stuff is needed to ensure a clean start
RUN rm -rf /run/httpd && mkdir /run/httpd

# Run as the root user
#USER root
USER 1001
# Launch httpd
CMD /usr/sbin/httpd -DFOREGROUND
