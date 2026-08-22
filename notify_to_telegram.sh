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

SCRIPT_VERSION="1.0.6"
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
                export UPDATED_FROM_VERSION="$SCRIPT_VERSION"
                exec "$SCRIPT_PATH" "$@"
            fi
        fi
        rm -f "$tmp_script"
    fi
}

# Run auto-update synchronously (short timeouts: ~5s max if no update, ~15s for full update)
# Enabled by default; disable with AUTO_UPDATE="false" in telegram_config.env (or legacy SKIP_UPDATE=1 env var)
if [ "${AUTO_UPDATE:-true}" = "true" ] && [ -z "$SKIP_UPDATE" ] && command -v curl &>/dev/null; then
    auto_update "$@"
fi

# Function to convert file sizes to human-readable format
function getFriendlyFileSize() {
    local size="$1"
    local __resultvar="$2"
    local val
    case "$size" in
        ''|*[!0-9]*)
            size=0
            ;;
    esac
    # ⚡ Bolt Optimization: Replaced awk subshells with native bash integer arithmetic to prevent fork/exec overhead.
    if [ "$size" -eq 0 ]; then
        val='-'
    elif [ "$size" -ge 1099511627776 ]; then
        val=$(( (size * 100 / 1099511627776 + 5) / 10 ))
        val="$((val / 10)).$((val % 10))Tb"
    elif [ "$size" -ge 1073741824 ]; then
        val=$(( (size * 100 / 1073741824 + 5) / 10 ))
        val="$((val / 10)).$((val % 10))Gb"
    elif [ "$size" -ge 1048576 ]; then
        val=$(( (size * 100 / 1048576 + 5) / 10 ))
        val="$((val / 10)).$((val % 10))Mb"
    elif [ "$size" -ge 1024 ]; then
        val=$(( (size * 100 / 1024 + 5) / 10 ))
        val="$((val / 10)).$((val % 10))Kb"
    else
        val='-'
    fi

    if [ -n "$__resultvar" ]; then
        printf -v "$__resultvar" "%s" "$val"
    else
        echo "$val"
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
            printf -v "RES_$key" "%s" "$val"
        fi
    done < "$DUPLICATI__RESULTFILE"
}

# Function to generate the result line with appropriate icon
function getResultLine () {
    local __resultvar="$1"
    # ⚡ Bolt Optimization: Replaced expensive `echo ... | sed ...` subshells with native bash string parameter expansion.
    # This avoids spawning child processes for string stripping, significantly improving script performance.
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

    local trimmed=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#"${line%%[![:blank:]]*}"}"
        line="${line%"${line##*[![:blank:]]}"}"
        if [ -n "$trimmed" ]; then
            trimmed="$trimmed"$'\n'"$line"
        else
            trimmed="$line"
        fi
    done <<< "$output"

    if [ -n "$__resultvar" ]; then
        printf -v "$__resultvar" "%s" "$trimmed"
    else
        echo "$trimmed"
    fi
}

# Function to handle fatal errors
function getResultFatal () {
    local __resultvar="$1"
    local output="
❗ <b>Error:</b> $RES_Failed
📋 <b>Details:</b> $RES_Details"

    local trimmed=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#"${line%%[![:blank:]]*}"}"
        line="${line%"${line##*[![:blank:]]}"}"
        if [ -n "$trimmed" ]; then
            trimmed="$trimmed"$'\n'"$line"
        else
            trimmed="$line"
        fi
    done <<< "$output"

    if [ -n "$__resultvar" ]; then
        printf -v "$__resultvar" "%s" "$trimmed"
    else
        echo "$trimmed"
    fi
}

# Function to handle restore operations
function getOperationRestore () {
    local __resultvar="$1"
    local s_restored s_deleted s_patched
    getFriendlyFileSize "$RES_SizeOfRestoredFiles" s_restored
    getFriendlyFileSize 0 s_deleted
    getFriendlyFileSize 0 s_patched

    local output
    printf -v output "\n📂 <b>FILES:</b>         count       size\n📥 <b>Restored:</b>     %7s %10s\n🗑️ <b>Deleted:</b>      %7s %10s\n🛠️ <b>Patched:</b>      %7s %10s\n———————————————————————————————\n📁 <b>FOLDERS:</b>\n📂 <b>Restored:</b>     %7s %10s\n🗑️ <b>Deleted:</b>      %7s %10s" \
        "$RES_RestoredFiles" "$s_restored" "$RES_DeletedFiles" "$s_deleted" "$RES_PatchedFiles" "$s_patched" \
        "$RES_RestoredFolders" "$s_deleted" "$RES_DeletedFolders" "$s_deleted"

    if [ -n "$__resultvar" ]; then
        printf -v "$__resultvar" "%s" "$output"
    else
        echo "$output"
    fi
}

# Function to handle backup operations
function getOperationBackup () {
    local __resultvar="$1"
    local s_add s_del s_mod s_opn s_exm s_fadd s_fdel s_fmod
    getFriendlyFileSize "$RES_SizeOfAddedFiles" s_add
    getFriendlyFileSize 0 s_del
    getFriendlyFileSize "$RES_SizeOfModifiedFiles" s_mod
    getFriendlyFileSize "$RES_SizeOfOpenedFiles" s_opn
    getFriendlyFileSize "$RES_SizeOfExaminedFiles" s_exm
    getFriendlyFileSize 0 s_fadd
    getFriendlyFileSize 0 s_fdel
    getFriendlyFileSize 0 s_fmod

    local output
    printf -v output "\n📂 <b>FILES:</b>         count       size\n➕ <b>Added:</b>        %7s %10s\n➖ <b>Deleted:</b>      %7s %10s\n🔧 <b>Changed:</b>      %7s %10s\n🔍 <b>Opened:</b>       %7s %10s\n🔎 <b>Examined:</b>     %7s %10s\n———————————————————————————————\n📁 <b>FOLDERS:</b>\n➕ <b>Added:</b>        %7s %10s\n➖ <b>Deleted:</b>      %7s %10s\n🔧 <b>Changed:</b>      %7s %10s" \
        "$RES_AddedFiles" "$s_add" "$RES_DeletedFiles" "$s_del" "$RES_ModifiedFiles" "$s_mod" \
        "$RES_OpenedFiles" "$s_opn" "$RES_ExaminedFiles" "$s_exm" "$RES_AddedFolders" "$s_fadd" \
        "$RES_DeletedFolders" "$s_fdel" "$RES_ModifiedFolders" "$s_fmod"

    if [ -n "$__resultvar" ]; then
        printf -v "$__resultvar" "%s" "$output"
    else
        echo "$output"
    fi
}

# Skip if operation is List
if [ "$DUPLICATI__OPERATIONNAME" == "List" ]; then exit 0; fi

# Generate message content
if [ "$DUPLICATI__EVENTNAME" == "AFTER" ]; then
    # ⚡ Bolt Optimization: Call parseResultFile once globally to avoid redundant disk I/O,
    # and use native bash parameter expansion to extract Duration without expensive grep/sed/tr subshells.
    parseResultFile
    Duration="${RES_Duration%%.*}"
    [ -z "$Duration" ] && Duration="--:--:--"
    getResultLine MESSAGE
    TEMP_MSG=""
    if [ "$DUPLICATI__OPERATIONNAME" == "Restore" ]; then
        getOperationRestore TEMP_MSG
        MESSAGE+="$TEMP_MSG"
    elif [ "$DUPLICATI__PARSED_RESULT" == "Fatal" ]; then
        getResultFatal TEMP_MSG
        MESSAGE+="$TEMP_MSG"
    else
        getOperationBackup TEMP_MSG
        MESSAGE+="$TEMP_MSG"
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

# Append script version info to the message
if [ -n "$UPDATED_FROM_VERSION" ] && [ "$UPDATED_FROM_VERSION" != "$SCRIPT_VERSION" ]; then
    MESSAGE+="🔄 <b>Script updated:</b> v${UPDATED_FROM_VERSION} → v${SCRIPT_VERSION}"
else
    MESSAGE+="⚙️ <b>Script version:</b> v${SCRIPT_VERSION}"
fi

# ⚡ Bolt Optimization: Execute curl in a detached subshell to prevent blocking the
# parent process (Duplicati) on network I/O latency.
(curl -s "$TELEGRAM_URL" -d chat_id="$TELEGRAM_CHATID" --data-urlencode "text=$MESSAGE" -d parse_mode="HTML" >/dev/null 2>&1 &)

exit 0