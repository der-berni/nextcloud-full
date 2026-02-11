FROM nextcloud:30.0-apache

########################################
#               Build                  #
########################################
ARG VERSION "30.0"
ARG DOWNLOADURL "https://github.com/nextcloud/docker"
ARG BUILD_DATE="2024-10-08T14:00:10Z"
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
        libmagickwand-dev \
        libgmp3-dev \
#        libc-client-dev \ # Throws error with Trixie
#        libkrb5-dev \ # Throws error with Trixie
        smbclient \
        libsmbclient-dev \
        inotify-tools \
    ;
# # # Workaround: libc-client-dev is installed from buster image
# Add Buster repository for libc-client-dev only
RUN echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list.d/buster.list

# Install libc-client-dev package from Buster repository
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev;

# Clean up the added repository and pin file
RUN rm /etc/apt/sources.list.d/buster.list && apt-get update;

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install bz2 gmp imap \
    && pecl install imagick smbclient \
    && docker-php-ext-enable imagick smbclient \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /var/log/supervisord \
    /var/run/supervisord \
;

COPY nextcloud-entrypoint.sh /
COPY supervisord.conf /etc/

ENTRYPOINT ["/nextcloud-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
