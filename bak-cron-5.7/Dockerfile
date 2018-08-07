FROM ez123/cron:alpine
MAINTAINER HighSkillz <webdev@highskillz.com>

ENV \
    DUMP_CRONTAB="0 0 * * *" \
    DUMP_UID="0" \
    DUMP_GID="0" \
    USE_DATE_IN_DEST="1" \
    MYSQLDUMP_OPTIONS="" \
    DUMP_USER_IF_NEW=dumpcron \
    BAK_NAME="untitled"

COPY ./src/mysqldump-entrypoint.sh /entrypoint.d/mysqldump.sh
COPY ./src/run-mysqldump.sh    /run-mysqldump.sh

RUN set -x; \
    apk add --no-cache --update \
        sudo \
        bash \
        coreutils \
        mysql-client \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    \
    && chmod +x \
        /entrypoint.d/*.sh \
        /run-*.sh \
    && mkdir -p \
        /mnt_dir/9.dst \
    && chmod a+rwx \
        /mnt_dir \
        /mnt_dir/9.dst \
    && echo done...

VOLUME ["/mnt_dir/9.dst"]
