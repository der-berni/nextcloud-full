FROM nextcloud:32.0-apache

########################################
#               Build                  #
########################################
ARG VERSION "32.0"
ARG DOWNLOADURL "https://github.com/nextcloud/docker"
ARG BUILD_DATE="2025-05-12T07:16:55Z"
########################################

# Basic build-time metadata as defined at http://label-schema.org
LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="AGPL-3.0 License" \
    org.label-schema.name="nextcloud-full" \
    org.label-schema.vendor="der-berni" \
    org.label-schema.version="Nextcloud v${NEXTCLOUD_VERSION}" \
    org.label-schema.description="A safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms." \
    org.label-schema.url="https://github.com/der-berni/nextcloud-full" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/der-berni/nextcloud-full.git" \
    maintainer="der-berni" \
    Author="t4skforce"


ENV NEXTCLOUD_UPDATE=1

RUN mkdir -p /usr/share/man/man1 \
    && apt-get update && apt-get install -y \
        supervisor \
        ffmpeg \
        smbclient \
        libsmbclient-dev \
        libbz2-dev \
        inotify-tools \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install bz2 \
    && docker-php-ext-enable smbclient 
COPY nextcloud-entrypoint.sh /
COPY supervisord.conf /etc/

ENTRYPOINT ["/nextcloud-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
