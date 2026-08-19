#!/bin/bash
escape_html() {
    local val="$1"
    val="${val//&/&amp;}"
    val="${val//</&lt;}"
    val="${val//>/&gt;}"
    echo "$val"
}

NAME="My <Backup> & Stuff"
NAME=$(escape_html "$NAME")
echo "$NAME"
