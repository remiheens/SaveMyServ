#!/bin/bash

#-----------------------------------------------------------#
# Backup web server (www+mysql)								#
# Auteur:		HEENS Remi 									#
# Date:			12 Avril 2010								#
#-----------------------------------------------------------#

#### MySQL credentials #####
user=saveuser
host=localhost
pass=resuevas

# MYSQLDUMP Options
OPTIONS="--add-drop-database --add-drop-table --complete-insert --routines --triggers --max_allowed_packet=50M --force"

# date of the day
DATE="$(date +"%d-%m-%Y")"

# destination folder for mysqldump
DESTINATION_DUMP="/var/sql/"

# source folder for www source
SOURCE_WWW="/var/www/"

# destination folder for entire backup
REP_BACKUP="/var/save/"

# remote destination folder for www
REP_DISTANT_WWW="/var/www/"
# remote destination folder for sql
REP_DISTANT_MYSQL="/var/sql/"

# remote destination folder for www
USER_SSH="usersave"
PWD_SSH="pwdssh"
SERVEUR_SSH="backup.srv"

# ! DONT MODIFY BELOW THIS LINE !

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
	mysqlcheck -u $user -h $host -p$pass -c -a $db
	mysqldump -u $user -h $host -p$pass $OPTIONS $db -R > $DESTINATION_DUMP"/"$db".sql";
done

#------------------------------------------------------------#
# Process SAUVEGARDE  										 #
#------------------------------------------------------------#
# SAVE de MySQL
rsync -rave ssh $DESTINATION_DUMP $USER_SSH"@"$SERVEUR_SSH":"$REP_DISTANT_MYSQL
#SAVE des sources www
rsync -rgpave ssh $SOURCE_WWW $USER_SSH"@"$SERVEUR_SSH":"$REP_DISTANT_WWW