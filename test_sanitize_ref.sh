#!/bin/bash
function sanitize_html() {
    local var_name="$1"
    local val="${!var_name}"
    val="${val//&/&amp;}"
    val="${val//</\&lt;}"
    val="${val//>/\&gt;}"
    printf -v "$var_name" "%s" "$val"
}

DUPLICATI__backup_name="Backup <Critical> & Data"
sanitize_html "DUPLICATI__backup_name"
echo "$DUPLICATI__backup_name"
