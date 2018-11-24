FROM library/ubuntu:bionic

# ARG can be overwritten on build time using "docker build --build-arg name=value"
# https://mathias-kettner.com/download.php
ARG CMK_VERSION_ARG="1.5.0p7"
ARG CMK_DOWNLOADNR_ARG="38"
ARG CMK_SITE_ARG="mva"
# cmkadmin password
ARG CMK_PASSWORD_ARG="omd"
ARG MAILHUB="undefined"

# After Build the ENV vars are initialized with the value of there build argument.
ENV CMK_VERSION=${CMK_VERSION_ARG}
ENV CMK_DOWNLOADNR=${CMK_DOWNLOADNR_ARG}
ENV CMK_SITE=${CMK_SITE_ARG}
ENV CMK_PASSWORD=${CMK_PASSWORD_ARG}
ENV MAILHUB=${MAILHUB}

# Install deps
RUN apt-get update
RUN apt-get install -y openssh-client samba-client ssmtp wget cron xinetd

# retrieve and install the check mk binaries and its dependencies
WORKDIR /tmp
RUN wget https://mathias-kettner.de/support/${CMK_VERSION_ARG}/check-mk-raw-${CMK_VERSION_ARG}_0.bionic_amd64.deb
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y ./check-mk-raw-${CMK_VERSION_ARG}_0.bionic_amd64.deb

# Add start scripts
ADD bootstrap.sh /opt/
ADD redirector.sh /opt/
ADD update.sh /opt/

RUN chmod +x /opt/bootstrap.sh
RUN chmod +x /opt/redirector.sh
RUN chmod +x /opt/update.sh

# Expose port 5000
EXPOSE 5000/tcp

# new site is now created on first startup (needs SYS_ADMIN capability!)
WORKDIR /omd
CMD bash /opt/bootstrap.sh