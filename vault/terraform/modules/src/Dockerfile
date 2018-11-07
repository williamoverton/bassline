FROM library/vault

RUN apk add python py-pip curl
RUN pip install pip --upgrade
RUN pip install awscli

COPY ./run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

COPY ./vault.hcl /opt/vault.hcl

EXPOSE 8200

CMD /opt/run.sh
