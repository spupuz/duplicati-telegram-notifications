#!/bin/bash
DUPLICATI__backup_name="My <Backup> & Stuff"
DUPLICATI__OPERATIONNAME="Backup"
DUPLICATI__PARSED_RESULT="Success"
DUPLICATI__EVENTNAME="AFTER"

for var in DUPLICATI__backup_name DUPLICATI__OPERATIONNAME DUPLICATI__PARSED_RESULT DUPLICATI__EVENTNAME; do
    val="${!var}"
    val="${val//&/&amp;}"
    val="${val//</&lt;}"
    val="${val//>/&gt;}"
    printf -v "$var" "%s" "$val"
done

echo "Name: $DUPLICATI__backup_name"
echo "Op: $DUPLICATI__OPERATIONNAME"
