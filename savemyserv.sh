#!/bin/bash

#-----------------------------------------------------------#
# Backup web server (www+mysql)                             #
# Auteur:               HEENS Remi                          #
# Date:                 12 Avril 2010                       #
#-----------------------------------------------------------#

#### MySQL credentials #####
user=userlogin
host=localhost
pass=userpwd

# MYSQLDUMP Options
OPTIONS="--add-drop-database --add-drop-table --complete-insert --routines --triggers --max_allowed_packet=50M --force"

# date of the day
DATE="$(date +"%d-%m-%Y")"

# destination folder for entire backup
REP_BACKUP="/home/backup/"
# source folder for www source
SOURCE_WWW="/var/www/"

# destination folder for mysqldump
DESTINATION_DUMP=$REP_BACKUP"sql/"

# remote destination folder for www
REP_DISTANT_WWW="/Users/remi/backup/www"
# remote destination folder for sql
REP_DISTANT_MYSQL="/Users/remi/backup/sql"

# remote destination folder for www
USER_SSH="user"
SERVEUR_SSH="backup.srv"

# ! DONT MODIFY BELOW THIS LINE !

#SAVE des sources www
rsync -rgpave ssh --exclude-from exclude-list.txt $SOURCE_WWW $USER_SSH"@"$SERVEUR_SSH":"$REP_DISTANT_WWW

if [ -d $DESTINATION_DUMP ];
then
        echo "Le repertoire existe";
else
        mkdir $DESTINATION_DUMP;
fi

# get list of database into this server mysql
LSTBASES="$(mysql -u $user -h $host -p$pass -Bse 'show databases')"

# on each database check and dump
for db in $LSTBASES
do
        #mysqlcheck -u $user -h $host -p$pass -c -a $db
        mysqldump -u $user -h $host -p$pass $OPTIONS $db -R > $DESTINATION_DUMP""$db".sql";
done

#------------------------------------------------------------#
# Process SAUVEGARDE                                         #
#------------------------------------------------------------#
# SAVE de MySQL
rsync -rave ssh $DESTINATION_DUMP $USER_SSH"@"$SERVEUR_SSH":"$REP_DISTANT_MYSQL