#!/bin/bash
# Mock environment to verify explicit empty state placeholders
export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1

# Clear potentially inherited env variables
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Fatal"
unset DUPLICATI__OPERATIONNAME
unset DUPLICATI__backup_name

export DUPLICATI__RESULTFILE="empty_dummy_result.txt"

# Ensure cleanup of test artifacts
trap 'rm -f empty_dummy_result.txt empty_debug.log' EXIT

# Empty result file
cat << 'RES' > empty_dummy_result.txt
RES

echo "Testing notify_to_telegram.sh Empty States..."
bash -x notify_to_telegram.sh > empty_debug.log 2>&1

OUTPUT=$(grep -A 20 'MESSAGE+=' empty_debug.log)

if [[ "$OUTPUT" == *"Unknown Task"* ]] && \
   [[ "$OUTPUT" == *"Unknown Operation"* ]] && \
   [[ "$OUTPUT" == *"Unknown Error"* ]] && \
   [[ "$OUTPUT" == *"No additional details provided."* ]]; then
    echo "Test passed: Empty states verified."
else
    echo "Test failed: Missing empty states in output."
    echo "Output:"
    echo "$OUTPUT"
fi
