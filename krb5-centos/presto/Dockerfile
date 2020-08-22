FROM prestosql/presto:330

# Obtain root privileges 
USER 0

# Kerberos client configuration
ENV KRB5_CONFIG="/etc/krb5.conf"
COPY ./services/krb5/client/krb5.conf /etc/krb5.conf

# Setup entrypoint
COPY ./services/presto/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/lib/presto/bin/run-presto"]

# Expose HTTPS
EXPOSE 7778

# Restore user
USER presto:presto
