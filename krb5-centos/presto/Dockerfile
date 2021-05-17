FROM starburstdata/presto:338-e.7

# Obtain root privileges 
USER 0

# Kerberos client configuration
ENV KRB5_CONFIG="/etc/krb5.conf"
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf

# Setup entrypoint
COPY ./services/presto/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose HTTPS
EXPOSE 7778

# Restore user
USER presto:presto
