FROM jlesage/baseimage-gui:ubuntu-24.04-v4.6

ARG BISQ_VERSION=1.9.16

ENV BISQ_DEBFILE Bisq-64bit-$BISQ_VERSION.deb
ENV BISQ_DOL_URL https://github.com/bisq-network/bisq/releases/download/v$BISQ_VERSION/$BISQ_DEBFILE
ENV BISQ_ASC_URL https://github.com/bisq-network/bisq/releases/download/v$BISQ_VERSION/$BISQ_DEBFILE.asc
ENV BISQ_PGP_KEY B493319106CC3D1F252E19CBF806F422E222AA02

WORKDIR /tmp

RUN \
    apt update \
    && apt install -y \
        java-common \
        openjdk-8-jre \
        libgtk-3-dev \
        openjfx \
        fonts-dejavu \
        wget \
        binutils \
        gpg \
        gpg-agent \
        ca-certificates \
        xdg-utils

RUN mkdir -p ~/.gnupg && \
    echo "pinentry-mode loopback" >> ~/.gnupg/gpg.conf && \
    echo "allow-loopback-pinentry" >> ~/.gnupg/gpg-agent.conf

RUN \
    APP_ICON_URL="https://avatars.githubusercontent.com/u/6928048?s=256&v=4" && \
    install_app_icon.sh "$APP_ICON_URL"

RUN mkdir bisq-install \
    && cd bisq-install \
    && wget -qO $BISQ_DEBFILE "$BISQ_DOL_URL" \
    && wget -qO Bisq.asc "$BISQ_ASC_URL" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$BISQ_PGP_KEY" \
    && gpg --digest-algo SHA256 --verify Bisq.asc $BISQ_DEBFILE \
    && mkdir -p /usr/share/desktop-directories /usr/share/applications \
    && dpkg -i $BISQ_DEBFILE \
    && cd .. \
    && rm -rf bisq-install

RUN \
    set-cont-env APP_NAME "Bisq" && \
    set-cont-env DOCKER_IMAGE_VERSION "$BISQ_VERSION" && \
    true

LABEL \
  org.label-schema.name="bisq" \
  org.label-schema.description="A peer-to-peer bitcoin exchange system" \
  org.label-schema.version="${BISQ_VERSION:-dev}" \
  org.label-schema.vcs-url="https://github.com/bisq-network/bisq" \
  org.label-schema.schema-version="1.0"

COPY rootfs/ /

RUN mkdir -p /data && chown 1000:1000 /data

VOLUME ["/data"]

RUN chmod +x /startapp.sh

