FROM library/alpine

RUN apk add bash openrc squid

COPY ./run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

COPY squid.conf /etc/squid/squid.conf
RUN chmod 222 /etc/squid/squid.conf

EXPOSE 80
EXPOSE 443

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=squid

CMD bash /opt/run.sh
