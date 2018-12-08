FROM library/vault

# Update everything
RUN apk upgrade --update

RUN apk add python py-pip curl jq bash
RUN pip install pip --upgrade
RUN pip install awscli

COPY ./run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

COPY ./vault.hcl /opt/vault.hcl

EXPOSE 8200

CMD bash /opt/run.sh
