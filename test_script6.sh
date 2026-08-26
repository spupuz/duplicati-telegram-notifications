#!/bin/bash
export TELEGRAM_TOKEN="dummy_token"
export TELEGRAM_CHATID="12345"
export DUPLICATI__backup_name="Backup <test> & \"foo\""
export DUPLICATI__OPERATIONNAME="Backup & Sync"
export DUPLICATI__EVENTNAME="BEFORE"
export DUPLICATI__PARSED_RESULT="Success"
export SKIP_UPDATE=1

bash -x ./notify_to_telegram.sh
