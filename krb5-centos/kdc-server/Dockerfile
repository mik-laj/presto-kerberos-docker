# Dockerfile - kdc-server
#
# see docker-compose.yml

FROM centos:8

# build environment
WORKDIR /root/

# moving to old repos
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Dev stuff
RUN dnf -y install curl wget && dnf clean all

# fforego
RUN curl -OL https://github.com/metabase/forego/releases/download/stable/forego-stable-linux-amd64.tgz && \
    tar xf forego-stable-linux-amd64.tgz && \
    mv forego /usr/local/bin/forego

# kerberos server
RUN dnf -y install krb5-server krb5-libs && dnf clean all

# kerberos server configuration
ENV KRB5_CONFIG=/etc/krb5.conf
ENV KRB5_KDC_PROFILE=/var/kerberos/krb5kdc/kdc.conf
RUN mkdir -pv /var/kerberos/krb5kdc/
COPY ./services/krb5/server/kdc.conf /var/kerberos/krb5kdc/kdc.conf
COPY ./services/krb5/server/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf
RUN mkdir -pv /var/log/kerberos/ && \
    touch /var/log/kerberos/kadmin.log && \
    touch /var/log/kerberos/krb5lib.log && \
    touch /var/log/kerberos/krb5.log && \
    kdb5_util -r EXAMPLE.COM -P krb5 create -s

# forego configuration
COPY ./services/krb5/server/Procfile /root/Procfile

# kerberos utils
COPY ./services/krb5/server/utils /opt/kerberos-utils/

# entrypoint
COPY ./services/krb5/server/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# when container is starting
CMD ["forego", "start"]
