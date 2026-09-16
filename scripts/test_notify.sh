#!/bin/bash
export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export DUPLICATI__EVENTNAME="BEFORE"
export DUPLICATI__PARSED_RESULT="Success"
export DUPLICATI__OPERATIONNAME="Backup"
export DUPLICATI__backup_name="Test Backup"
export SKIP_UPDATE=1

echo "Testing notify_to_telegram.sh..."
if bash -n notify_to_telegram.sh && ./notify_to_telegram.sh; then
    echo "Test passed."
else
    echo "Test failed."
fi
