FROM alpine:latest

LABEL maintainer="Jozef Sabo"

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    EULA="false" \
    MC_RAM="" \
    JAVA_OPTS="" \
    USER_LIST="" \
    ACL=""

# ACL - access control list, working on bitwise AND (&) principle
# 1 - allow screen console, 2 - allow config editing, 4 - allow plugin uploading, editing and deleting

RUN apk update \
    && apk add openjdk17-jre \
    && apk add bash \
    && apk add wget \
    && apk add jq \
    && apk add openssh \
    && apk add tzdata \
    && apk add nano \
    && apk add supervisor\
    && apk add screen \
    && apk add coreutils \
    && apk add python3

# coreutils for tail --pid, because not in alpine

RUN chmod u+s /usr/bin/screen && chmod u+s /usr/bin/passwd

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# user runner - will run the script
RUN mkdir -p /uhome/runner && adduser -h /uhome/runner -s /bin/sh -D runner --uid 1000
RUN mkdir /papermc
RUN addgroup config && addgroup plugins

COPY privileged.sh papermc.sh event_listener.py /
RUN chmod u+x /privileged.sh && chmod o+x /papermc.sh

USER root

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord",  "-c", "/etc/supervisor/conf.d/supervisord.conf"]

VOLUME /papermc
VOLUME /home
VOLUME /var/log

EXPOSE 22
EXPOSE 25565/tcp
EXPOSE 25565/udp
