#!/bin/bash

#########################################################################
# Enhanced Script for Telegram Notifications about Duplicati Backup Results
# Released "AS IS" without any warranty of any kind.
#########################################################################

# Duplicati can run scripts before and after backups. This 
# functionality is available in the advanced options of any backup job (UI) or
# as option (CLI). The (advanced) options to run scripts are
# --run-script-before = your/path/notify_to_telegram.sh
# --run-script-after = your/path/notify_to_telegram.sh

# To work, you need to set two required variables:
#  TELEGRAM_TOKEN
#  TELEGRAM_CHATID
# These variables must be configured in 'telegram_config.env' located
# in the same directory as the script, or set as environment variables.
#
# DISCLAIMER (AS IS):
# This script is provided "as is", without warranty of any kind, express or
# implied. In no event shall the authors or copyright holders be liable for
# any claim, damages, data loss or other liability arising from its use.
#########################################################################

# 1. Locate the script directory to load the relative configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_FILE="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_FILE"

SCRIPT_VERSION="1.0.1"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/spupuz/duplicati-telegram-notifications/main"
CONFIG_FILE="${SCRIPT_DIR}/telegram_config.env"

# 2. Load variables from config file if it exists, cleaning Windows CRLF line endings (\r)
if [ -f "$CONFIG_FILE" ]; then
    source <(tr -d '\r' < "$CONFIG_FILE")
fi

# 3. Verify presence of required variables (loaded from config or inherited from env)
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHATID" ]; then
    echo "Error: TELEGRAM_TOKEN or TELEGRAM_CHATID is not configured!" >&2
    echo "Please create a 'telegram_config.env' file in the same directory as the script" >&2
    echo "or set the corresponding environment variables." >&2
    exit 1
fi

TELEGRAM_URL="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"

# Auto-update: check GitHub for a newer version and replace itself
auto_update() {
    local latest_version tmp_script
    latest_version=$(curl -s --max-time 5 "$GITHUB_RAW_BASE/version.txt" 2>/dev/null | tr -d '\r\n')
    [ -z "$latest_version" ] && return

    if [ "$latest_version" != "$SCRIPT_VERSION" ] && [ "$(printf '%s\n' "$SCRIPT_VERSION" "$latest_version" | sort -V | tail -1)" = "$latest_version" ]; then
        tmp_script=$(mktemp)
        if curl -s --max-time 10 -o "$tmp_script" "$GITHUB_RAW_BASE/notify_to_telegram.sh" 2>/dev/null && [ -s "$tmp_script" ]; then
            head -1 "$tmp_script" | grep -q "^#!/bin/bash" || { rm -f "$tmp_script"; return; }
            if ! diff -q "$tmp_script" "$SCRIPT_PATH" &>/dev/null; then
                cp "$tmp_script" "$SCRIPT_PATH" && chmod +x "$SCRIPT_PATH"
                rm -f "$tmp_script"
                exec "$SCRIPT_PATH" "$@"
            fi
        fi
        rm -f "$tmp_script"
    fi
}

# Run auto-update synchronously (short timeouts: ~5s max if no update, ~15s for full update)
if [ -z "$SKIP_UPDATE" ] && command -v curl &>/dev/null; then
    auto_update "$@"
fi

# Function to convert file sizes to human-readable format
function getFriendlyFileSize() {
    local size="$1"
    local val
    case "$size" in
        ''|*[!0-9]*)
            size=0
            ;;
    esac
    # ⚡ Bolt Optimization: Replaced awk subshells with native bash integer arithmetic to prevent fork/exec overhead.
    if [ "$size" -eq 0 ]; then
        echo '-'
    elif [ "$size" -ge 1099511627776 ]; then
        val=$(( (size * 100 / 1099511627776 + 5) / 10 ))
        echo "$((val / 10)).$((val % 10))Tb"
    elif [ "$size" -ge 1073741824 ]; then
        val=$(( (size * 100 / 1073741824 + 5) / 10 ))
        echo "$((val / 10)).$((val % 10))Gb"
    elif [ "$size" -ge 1048576 ]; then
        val=$(( (size * 100 / 1048576 + 5) / 10 ))
        echo "$((val / 10)).$((val % 10))Mb"
    elif [ "$size" -ge 1024 ]; then
        val=$(( (size * 100 / 1024 + 5) / 10 ))
        echo "$((val / 10)).$((val % 10))Kb"
    else
        echo '-'
    fi
}

# Securely parse the result file to avoid command injection
function parseResultFile () {
    [ -f "$DUPLICATI__RESULTFILE" ] || return
    while IFS=':' read -r key val || [ -n "$key" ]; do
        key="${key//[[:space:]]/}"
        val="${val#"${val%%[![:space:]]*}"}"
        val="${val%$'\r'}"
        if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            printf -v "$key" "%s" "$val"
        fi
    done < "$DUPLICATI__RESULTFILE"
}

# Function to generate the result line with appropriate icon
function getResultLine () {
    # ⚡ Bolt Optimization: Replaced expensive `echo ... | sed ...` subshells with native bash `case` statements.
    # This avoids spawning child processes for simple string mapping, significantly improving script performance.
    case "$DUPLICATI__EVENTNAME" in
        BEFORE) CURRENT_STATUS="Started" ;;
        AFTER)  CURRENT_STATUS="Finished" ;;
        *)      CURRENT_STATUS="$DUPLICATI__EVENTNAME" ;;
    esac

    case "$DUPLICATI__PARSED_RESULT" in
        Unknown) RESULT_ICON="🟣" ;;
        Success) RESULT_ICON="✅" ;;
        Warning) RESULT_ICON="⚠️" ;;
        Error)   RESULT_ICON="❌" ;;
        Fatal)   RESULT_ICON="💥" ;;
        *)       RESULT_ICON="$DUPLICATI__PARSED_RESULT" ;;
    esac

    local output="<b>💾 DUPLICATI BACKUP</b>
<pre>
———————————————————————————————
📋 <b>Task:</b>      $DUPLICATI__backup_name
⚙️ <b>Operation:</b> $DUPLICATI__OPERATIONNAME
📊 <b>Status:</b>    $CURRENT_STATUS
${RESULT_ICON} <b>Result:</b>    $DUPLICATI__PARSED_RESULT
———————————————————————————————
⏱ <b>Duration:</b>  $Duration
———————————————————————————————"
    echo "$output" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Function to handle fatal errors
function getResultFatal () {
    parseResultFile
    local output="
❗ <b>Error:</b> $Failed
📋 <b>Details:</b> $Details"
    echo "$output" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Function to handle restore operations
function getOperationRestore () {
    parseResultFile
    local output="
📂 <b>FILES:</b>         count       size
📥 <b>Restored:</b>     $(printf %7s $RestoredFiles) $(printf %10s $(getFriendlyFileSize $SizeOfRestoredFiles))
🗑️ <b>Deleted:</b>      $(printf %7s $DeletedFiles) $(printf %10s $(getFriendlyFileSize 0))
🛠️ <b>Patched:</b>      $(printf %7s $PatchedFiles) $(printf %10s $(getFriendlyFileSize 0))
———————————————————————————————
📁 <b>FOLDERS:</b>
📂 <b>Restored:</b>     $(printf %7s $RestoredFolders) $(printf %10s $(getFriendlyFileSize 0))
🗑️ <b>Deleted:</b>      $(printf %7s $DeletedFolders) $(printf %10s $(getFriendlyFileSize 0))"
    echo "$output" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Function to handle backup operations
function getOperationBackup () {
    parseResultFile
    local output="
📂 <b>FILES:</b>         count       size
➕ <b>Added:</b>        $(printf %7s $AddedFiles) $(printf %10s $(getFriendlyFileSize $SizeOfAddedFiles))
➖ <b>Deleted:</b>      $(printf %7s $DeletedFiles) $(printf %10s $(getFriendlyFileSize 0))
🔧 <b>Changed:</b>      $(printf %7s $ModifiedFiles) $(printf %10s $(getFriendlyFileSize $SizeOfModifiedFiles))
🔍 <b>Opened:</b>       $(printf %7s $OpenedFiles) $(printf %10s $(getFriendlyFileSize $SizeOfOpenedFiles))
🔎 <b>Examined:</b>     $(printf %7s $ExaminedFiles) $(printf %10s $(getFriendlyFileSize $SizeOfExaminedFiles))
———————————————————————————————
📁 <b>FOLDERS:</b>
➕ <b>Added:</b>        $(printf %7s $AddedFolders) $(printf %10s $(getFriendlyFileSize 0))
➖ <b>Deleted:</b>      $(printf %7s $DeletedFolders) $(printf %10s $(getFriendlyFileSize 0))
🔧 <b>Changed:</b>      $(printf %7s $ModifiedFolders) $(printf %10s $(getFriendlyFileSize 0))"
    echo "$output" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# Skip if operation is List
if [ "$DUPLICATI__OPERATIONNAME" == "List" ]; then exit 0; fi

# Generate message content
if [ "$DUPLICATI__EVENTNAME" == "AFTER" ]; then
    Duration=$(grep -oP '^Duration:\s*\K.*' "$DUPLICATI__RESULTFILE" | sed 's/\.[0-9]*$//' | tr -d '\r')
    [ -z "$Duration" ] && Duration="--:--:--"
    MESSAGE=$(getResultLine)
    if [ "$DUPLICATI__OPERATIONNAME" == "Restore" ]; then
        MESSAGE+=$(getOperationRestore)
    elif [ "$DUPLICATI__PARSED_RESULT" == "Fatal" ]; then
        MESSAGE+=$(getResultFatal)
    else
        MESSAGE+=$(getOperationBackup)
    fi
else
    # ⚡ Bolt Optimization: Replaced `echo | sed` subshell with native bash `case` statement to prevent fork/exec overhead.
    case "$DUPLICATI__EVENTNAME" in
        BEFORE) CURRENT_STATUS="Started" ;;
        AFTER)  CURRENT_STATUS="Finished" ;;
        *)      CURRENT_STATUS="$DUPLICATI__EVENTNAME" ;;
    esac
    MESSAGE="<b>💾 DUPLICATI BACKUP</b>
<pre>
———————————————————————————————
📋 <b>Task:</b>      $DUPLICATI__backup_name
⚙️ <b>Operation:</b> $DUPLICATI__OPERATIONNAME
📊 <b>Status:</b>    $CURRENT_STATUS
</pre>"
fi

# Send message to Telegram with HTML formatting
MESSAGE+="
</pre>"
curl -s $TELEGRAM_URL -d chat_id=$TELEGRAM_CHATID -d text="$MESSAGE" -d parse_mode="HTML" -k > /dev/null

exit 0