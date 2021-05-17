FROM starburstdata/presto:338-e.7

# Obtain root privileges 
USER 0

# Kerberos client configuration
ENV KRB5_CONFIG="/etc/krb5.conf"
ENV KRB5_KTNAME="/home/presto/kerberos.keytab"
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf


# Kerberos/SSL configuration
ENV JKS_KEYSTORE_FILE="/home/presto/ssl_keystore.jks"
ENV JKS_KEYSTORE_PASS="presto"

RUN JVM_CONFIG="/usr/lib/presto/etc/jvm.config" && \
    echo "-Dsun.security.krb5.debug=true" >> "${JVM_CONFIG}" && \
    echo "-Dlog.enable-console=true" >> "${JVM_CONFIG}" && \
    PRESTO_CONFIG="/usr/lib/presto/etc/config.properties" && \
    echo "http-server.authentication.type=KERBEROS" >> "${PRESTO_CONFIG}" && \
    echo "http-server.authentication.krb5.service-name=HTTP" >> "${PRESTO_CONFIG}" && \
    echo "http-server.authentication.krb5.principal-hostname=krb5-presto-example-com.example.com" >> "${PRESTO_CONFIG}" && \
    echo "http-server.authentication.krb5.keytab=${KRB5_KTNAME}" >> "${PRESTO_CONFIG}" && \
    echo "http.authentication.krb5.config=${KRB5_CONFIG}" >> "${PRESTO_CONFIG}" && \
    echo "http-server.https.enabled=true" >> "${PRESTO_CONFIG}" && \
    echo "http-server.https.port=7778" >> "${PRESTO_CONFIG}" && \
    echo "http-server.https.keystore.path=${JKS_KEYSTORE_FILE}" >> "${PRESTO_CONFIG}" && \
    echo "http-server.https.keystore.key=${JKS_KEYSTORE_PASS}"  >> "${PRESTO_CONFIG}" && \
    echo "node.internal-address-source=FQDN" >> "${PRESTO_CONFIG}"

# Expose HTTPS
EXPOSE 7778

# Restore user
USER presto:presto
