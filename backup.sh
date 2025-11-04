#!/bin/sh

export MYSQL_PWD=${DB_PASSWORD}

# Attente que MySQL soit prêt
until mysql -hmysql -u${DB_USER} -e 'SELECT 1;' >/dev/null 2>&1; do
  echo 'Waiting for MySQL...'
  sleep 5
done

echo 'MySQL ready, starting backups every 12 hours...'

while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE=/backups/${DB_NAME}_$TIMESTAMP.sql.gz

  if mysqldump --no-tablespaces -hmysql -u${DB_USER} ${DB_NAME} | gzip > "$BACKUP_FILE"; then
    echo "Backup successful: $BACKUP_FILE"
    find /backups -type f -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete
    echo "Old backups cleaned"
  else
    echo "Backup FAILED!" >&2
  fi

  sleep 43200
done
