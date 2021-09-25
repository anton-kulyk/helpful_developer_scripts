#!/bin/bash

# options
LOCAL_DIR="~/dbs_temp"
REMOTE_DIR="/root/dbs_temp"
SERVER_USER="root"
SERVER_IP="PUT SERVER IP HERE"

# static
DB=$1
REMOTE_SERVER=${SERVER_USER}@${SERVER_IP}

function print_message(){
  echo "=>" $1
}

if [ -z "$DB" ]
then
    print_message "DB is empty"
    exit
fi

### REMOTE

# remote mysql dump and zip
print_message "connecting to ${SERVER_IP} via ${SERVER_USER}..."
print_message "creating dump of ${DB}"
print_message "adding DB dump to ${REMOTE_DIR}/${DB}.zip"
ssh ${REMOTE_SERVER} "cd ${REMOTE_DIR} && mysqldump ${DB} > ${DB}.sql && zip ${DB}.zip ${DB}.sql"

# copy from server to local
print_message "copy file /root/${DB}.zip to local machine at ${LOCAL_DIR}"
scp ${REMOTE_SERVER}:${REMOTE_DIR}/${DB}.zip ${LOCAL_DIR}

# remove remote sql and zip
print_message "remove remote files ${REMOTE_DIR}/${DB}.sql"
ssh ${REMOTE_SERVER} "rm ${REMOTE_DIR}/${DB}.sql"


### LOCAL

# unzip local zip
print_message "inflating zip archive ${LOCAL_DIR}/${DB}.zip"
cd ${LOCAL_DIR} && unzip -o ${DB}.zip

print_message "import database to local $DB"
mysql --execute="DROP DATABASE IF EXISTS $DB"
mysql --execute="CREATE DATABASE $DB CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# import to local database
print_message "import database to ${DB}.sql"
cd ${LOCAL_DIR} && mysql ${DB} < ${DB}.sql

# remove local zip and sql
print_message "remove local sql file ${LOCAL_DIR}/${DB}.sql"
rm ${LOCAL_DIR}/${DB}.sql

############################################################################
### UNCOMMENT COMMANDS BELOW IF YOU NEED TO WORK WITH WORDPRESS DATABASE ###
############################################################################

# change .com.ua to .loc
#print_message "update siteurl and home options"
#mysql --database="${DB}" --execute="UPDATE wp_options SET option_value=REPLACE( option_value, '.com.ua', '.loc' ) WHERE option_name IN ('siteurl', 'home' )"

# change .kiev.ua to .loc
#print_message "update siteurl and home options"
#mysql --database="${DB}" --execute="UPDATE wp_options SET option_value=REPLACE( option_value, '.kiev.ua', '.loc' ) WHERE option_name IN ('siteurl', 'home' )"

# change .com to .loc
#print_message "update siteurl and home options"
#mysql --database="${DB}" --execute="UPDATE wp_options SET option_value=REPLACE( option_value, '.com', '.loc' ) WHERE option_name IN ('siteurl', 'home' )"

# remove www from the domain
#print_message "remove www. from the domain name"
#mysql --database="${DB}" --execute="UPDATE wp_options SET option_value=REPLACE( option_value, 'www.', '' ) WHERE option_name IN ('siteurl', 'home' )"
