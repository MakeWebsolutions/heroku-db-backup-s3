#!/bin/bash

DBNAME=""
EXPIRATION="30"
Green='\033[0;32m'
EC='\033[0m' 
FILENAME=`date +%H_%M_%d%m%Y`

# terminate script on any fails
set -e

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -exp|--expiration)
    EXPIRATION="$2"
    shift
    ;;
    -db|--dbname)
    DBNAME="$2"
    shift
    ;;
esac
shift
done

if [[ -z "$DBNAME" ]]; then
  echo "Missing DBNAME variable"
  exit 1
fi
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "Missing AWS_ACCESS_KEY_ID variable"
  exit 1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Missing AWS_SECRET_ACCESS_KEY variable"
  exit 1
fi
if [[ -z "$AWS_REGION" ]]; then
  echo "Missing AWS_REGION variable"
  exit 1
fi
if [[ -z "$BACKUP_S3_BUCKET" ]]; then
  echo "Missing BACKUP_S3_BUCKET variable"
  exit 1
fi
if [[ -z "$DATABASE_URL" ]]; then
  echo "Missing DATABASE_URL variable"
  exit 1
fi
if [[ -z "$BACKUP_S3_PASSWORD" ]]; then
  echo "Missing BACKUP_S3_PASSWORD variable"
  exit 1
fi

printf "${Green}Start dump${EC}"

time pg_dump -F c --no-acl --no-owner --quote-all-identifiers $DATABASE_URL | gzip >  /tmp/"${DBNAME}_${FILENAME}".gz

gpg --yes --batch --passphrase=$BACKUP_S3_PASSWORD -c /tmp/"${DBNAME}_${FILENAME}".gz

rm -rf /tmp/"${DBNAME}_${FILENAME}".gz

EXPIRATION_DATE=$(date -d "$EXPIRATION days" +"%Y-%m-%dT%H:%M:%SZ")

printf "${Green}Move dump to AWS${EC}"
time /app/vendor/awscli/bin/aws s3 cp /tmp/"${DBNAME}_${FILENAME}".gz.gpg s3://$BACKUP_S3_BUCKET/$DBNAME/"${DBNAME}_${FILENAME}".gz.gpg --expires $EXPIRATION_DATE

rm -rf /tmp/"${DBNAME}_${FILENAME}".gz.gpg