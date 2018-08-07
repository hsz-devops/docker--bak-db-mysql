#!/usr/bin/env bash
set -ex

echo $UID $GID $(whoami)

[ -z "$1" ] && echo "Cron job UID parameter not specified" && exit -1
[ -z "$2" ] && echo "Cron job GID parameter not specified" && exit -2

### extract year, month, day to create sub-directories and format date to append to backup name.
T_STAMP=$(date -u  "+%Y%m%d_%H%M%SZ")
echo "current timestamp is: ${T_STAMP}"

BACKUP_ROOT="/mnt_dir"
BACKUP_ROOT_DST="${BACKUP_ROOT}/9.dst"

ls -la "${BACKUP_ROOT}"     ||true
ls -la "${BACKUP_ROOT_DST}" ||true

[ -d "${BACKUP_ROOT_DST}" ] || exit -4

if [ "${USE_DATE_IN_DEST}" == "1" ]; then
    CURRENT_YEAR="${T_STAMP:0:4}"
    CURRENT_MONTH="${T_STAMP:4:2}"
    CURRENT_DAY="${T_STAMP:6:2}"
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_DAY}"

    ### create backups directory if not present
    mkdir -p "${BACKUP_DIR_DST}"
else
    BACKUP_DIR_DST="${BACKUP_ROOT_DST}"
fi

ls -la "${BACKUP_DIR_DST}" ||true
[ -d "${BACKUP_DIR_DST}" ] || exit -5

## make sure folder is writeable by the user
## but not recursivelly (there may already be some files from previous backups in same day)
chown "$1":"$2" "${BACKUP_DIR_DST}"

echo "backup directory: ${BACKUP_DIR_DST}"

# BAK_ARCHIVE_NAME="${BACKUP_DIR_DST}/${BAK_NAME}.${T_STAMP}.tar.gz"


# -----------------------------------
### start creating mysqldump command
mysqldump_cmd="mysqldump "

if [ "${MYSQL__SSL_DISABLED}" == "no" ]; then
    export MYSQL__SSL_MODE="REQUIRED"
    export MYSQL__SSL_KEYFILE_PATH="${MYSQL__SSL_KEYFILE_PATH:-/etc/ssl/mysql-key.pem}"
    export MYSQL__SSL_CERT_PATH="${MYSQL__SSL_CERT_PATH:-/etc/ssl/mysql-cert.pem}"

    mysqldump_cmd="$mysqldump_cmd --ssl-mode=${MYSQL__SSL_MODE}"
    mysqldump_cmd="$mysqldump_cmd --ssl-key=${MYSQL__SSL_KEYFILE_PATH} --ssl-cert=${MYSQL__SSL_CERT_PATH}"
fi

[ -z "${MYSQL__HOST}"     ] && echo "Using localhost as the database server to backup." || mysqldump_cmd="${mysqldump_cmd} --host=\"${MYSQL__HOST}\" "
[ -z "${MYSQL__PORT}"     ] && echo "Using default mysql port to connect."              || mysqldump_cmd="${mysqldump_cmd} --port=${MYSQL__PORT} "
[ -z "${MYSQL__USERNAME}" ] && mysqldump_cmd="${mysqldump_cmd} --user=root" || mysqldump_cmd="${mysqldump_cmd} --user=${MYSQL__USERNAME}"
[ -z "${MYSQL__PASSWORD}" ] && mysqldump_cmd="${mysqldump_cmd}"             || mysqldump_cmd="${mysqldump_cmd} --password='${MYSQL__PASSWORD}' "

mysqldump_cmd="${mysqldump_cmd} ${MYSQLDUMP_OPTIONS} "

if [ -z "${MYSQL__DB_NAME}" ]; then
    echo "No DB name supplied. Dumping all databases..."
    # dump all databases to single file
    BACKUP_NAME="all--${BAK_NAME}"
    mysqldump_cmd="$mysqldump_cmd  --all-databases"
else
    echo "Dumping only [${MYSQL__DB_NAME}] database..."
    # dump single database to single file
    BACKUP_NAME="${BAK_NAME}"
    mysqldump_cmd="${mysqldump_cmd} ${MYSQL__DB_NAME}"
fi

mysqldump_cmd="$mysqldump_cmd | gzip -9 > ${BACKUP_DIR_DST}/${BACKUP_NAME}.${T_STAMP}.sql.gz"

echo "the final command is  ${mysqldump_cmd}"

### execute mysqldump command, which will dump the db into an archive
eval "sudo -u '$1' -g '$2' ${mysqldump_cmd}"
