#!/bin/bash
DUPLICATI__backup_name="Backup <Critical> & Data"
DUPLICATI__OPERATIONNAME="Backup"
DUPLICATI__PARSED_RESULT="Error"
DUPLICATI__EVENTNAME="AFTER"
DUPLICATI__RESULTFILE="dummy.txt"
cat << 'DUMMY' > dummy.txt
Duration: 00:00:05.123
Failed: File <config.js> not found
Details: Error & exception at line 1
DUMMY

# SCRIPT LOGIC
function parseResultFile () {
    [ -f "$DUPLICATI__RESULTFILE" ] || return
    while IFS=':' read -r key val || [ -n "$key" ]; do
        key="${key//[[:space:]]/}"
        val="${val#"${val%%[![:space:]]*}"}"
        val="${val%$'\r'}"
        if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            printf -v "RES_$key" "%s" "$val"
        fi
    done < "$DUPLICATI__RESULTFILE"
}

# Add sanitization
for var in DUPLICATI__backup_name DUPLICATI__OPERATIONNAME DUPLICATI__PARSED_RESULT DUPLICATI__EVENTNAME; do
    val="${!var}"
    val="${val//&/&amp;}"
    val="${val//</&lt;}"
    val="${val//>/&gt;}"
    printf -v "$var" "%s" "$val"
done

parseResultFile
for var in RES_Failed RES_Details; do
    val="${!var}"
    val="${val//&/&amp;}"
    val="${val//</&lt;}"
    val="${val//>/&gt;}"
    printf -v "$var" "%s" "$val"
done

echo "Backup name: $DUPLICATI__backup_name"
echo "Failed: $RES_Failed"
