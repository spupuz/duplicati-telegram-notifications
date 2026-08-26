#!/bin/bash
escape_html_var() {
    # Disable patsub_replacement if it exists (Bash 5.2+)
    shopt -u patsub_replacement 2>/dev/null || true

    local varname="$1"
    local val="${!varname}"
    val="${val//&/&amp;}"
    val="${val//</&lt;}"
    val="${val//>/&gt;}"
    printf -v "$varname" "%s" "$val"
}

DUPLICATI__backup_name="Backup <test> & \"foo\""
escape_html_var DUPLICATI__backup_name
echo "escaped: $DUPLICATI__backup_name"
