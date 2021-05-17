# Dockerfile - machine
#
# see docker-compose.yml

FROM centos:8

# build environment
WORKDIR /root/

# Kerberos client
RUN dnf -y install curl wget krb5-workstation krb5-libs

# Kerberos client configuration
ENV KRB5_CONFIG=/etc/krb5.conf
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf

# when container is starting
CMD ["bash", "-c", "Helllo world"]
