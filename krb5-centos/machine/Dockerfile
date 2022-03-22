# Dockerfile - machine
#
# see docker-compose.yml

FROM centos:8

# build environment
WORKDIR /root/

RUN cd /etc/yum.repos.d/ &&  \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Dev stuff
RUN dnf -y install curl wget && dnf clean all

# Kerberos client
RUN dnf -y install krb5-workstation krb5-libs && dnf clean all

# Kerberos client configuration
ENV KRB5_CONFIG=/etc/krb5.conf
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf

# when container is starting
CMD ["bash", "-c", "Helllo world"]
