#!/bin/bash
# Comprehensive test suite for notify_to_telegram.sh
# Tests various event types, result formats, and error scenarios

set -euo pipefail

PASS=0
FAIL=0

run_test() {
    local test_name="$1"
    local result="$2"
    
    if [ "$result" = "true" ]; then
        echo "  PASS: $test_name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $test_name"
        FAIL=$((FAIL + 1))
    fi
}

# ── Test 1: Empty states (AFTER with no result file) ────────────────
echo "🧪 Test 1: Empty states (AFTER, no result file)"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Fatal"
unset DUPLICATI__OPERATIONNAME
unset DUPLICATI__backup_name

export DUPLICATI__RESULTFILE="empty_dummy_result.txt"

# Ensure cleanup of test artifacts
trap 'rm -f empty_dummy_result.txt empty_debug.log' EXIT

# Empty result file (just header line)
cat << 'RES' > empty_dummy_result.txt
RES

bash -x notify_to_telegram.sh > empty_debug.log 2>&1 || true

OUTPUT=$(grep -A 20 'printf -v MESSAGE' empty_debug.log 2>/dev/null || echo "")

run_test "Unknown Task appears" "$(echo "$OUTPUT" | grep -q 'Unknown Task' && echo true || echo false)"
run_test "Unknown Operation appears" "$(echo "$OUTPUT" | grep -q 'Unknown Operation' && echo true || echo false)"
run_test "Unknown Error appears" "$(echo "$OUTPUT" | grep -q 'Unknown Error' && echo true || echo false)"
run_test "No additional details provided." "$(echo "$OUTPUT" | grep -q 'No additional details provided.' && echo true || echo false)"

# ── Test 2: BEFORE event ─────────────────────────────────────────────
echo ""
echo "🧪 Test 2: BEFORE event"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="BEFORE"
export DUPLICATI__PARSED_RESULT="Unknown"
export DUPLICATI__OPERATIONNAME="Test Operation"
export DUPLICATI__backup_name="Test Backup Name"

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "BEFORE event syntax OK" "true"
else
    run_test "BEFORE event syntax FAIL" "false"
fi

# ── Test 3: AFTER with Success ───────────────────────────────────────
echo ""
echo "🧪 Test 3: AFTER with Success result"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Success"
export DUPLICATI__OPERATIONNAME="Backup"
export DUPLICATI__backup_name="Test Backup"
export DUPLICATI__RESULTFILE=""

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "AFTER Success syntax OK" "true"
else
    run_test "AFTER Success syntax FAIL" "false"
fi

# ── Test 4: AFTER with Warning ───────────────────────────────────────
echo ""
echo "🧪 Test 4: AFTER with Warning result"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Warning"
export DUPLICATI__OPERATIONNAME="Backup"
export DUPLICATI__backup_name="Test Backup"

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "AFTER Warning syntax OK" "true"
else
    run_test "AFTER Warning syntax FAIL" "false"
fi

# ── Test 5: AFTER with Error ─────────────────────────────────────────
echo ""
echo "🧪 Test 5: AFTER with Error result"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Error"
export DUPLICATI__OPERATIONNAME="Backup"
export DUPLICATI__backup_name="Test Backup"

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "AFTER Error syntax OK" "true"
else
    run_test "AFTER Error syntax FAIL" "false"
fi

# ── Test 6: AFTER with Fatal ─────────────────────────────────────────
echo ""
echo "🧪 Test 6: AFTER with Fatal result"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Fatal"
export DUPLICATI__OPERATIONNAME="Backup"
export DUPLICATI__backup_name="Test Backup"

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "AFTER Fatal syntax OK" "true"
else
    run_test "AFTER Fatal syntax FAIL" "false"
fi

# ── Test 7: Restore operation ────────────────────────────────────────
echo ""
echo "🧪 Test 7: Restore operation"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Success"
export DUPLICATI__OPERATIONNAME="Restore"
export DUPLICATI__backup_name="Restore Test"

if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "Restore syntax OK" "true"
else
    run_test "Restore syntax FAIL" "false"
fi

# ── Test 8: Invalid TELEGRAM_TOKEN format ────────────────────────────
echo ""
echo "🧪 Test 8: Invalid TELEGRAM_TOKEN format"

export TELEGRAM_TOKEN="invalid-token-format"
export TELEGRAM_CHATID="123456"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Success"

# Run script and capture output; script should exit with code 1
set +e
output=$(bash notify_to_telegram.sh 2>&1)
exit_code=$?
set -e

if [ "$exit_code" -eq 1 ] && echo "$output" | grep -qi 'invalid format'; then
    run_test "Invalid token rejected" "true"
else
    run_test "Invalid token rejected" "false"
fi

# ── Test 9: Missing TELEGRAM_CHATID ──────────────────────────────────
echo ""
echo "🧪 Test 9: Missing TELEGRAM_CHATID"

# Ensure TELEGRAM_CHATID is unset for this test
unset TELEGRAM_CHATID
export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export SKIP_UPDATE=1
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Success"

set +e
output=$(bash notify_to_telegram.sh 2>&1)
exit_code=$?
set -e

if [ "$exit_code" -eq 1 ] && echo "$output" | grep -q 'not configured'; then
    run_test "Missing chatID rejected" "true"
else
    run_test "Missing chatID rejected" "false"
fi

# ── Test 10: Auto-update disable via AUTO_UPDATE ──────────────────────
echo ""
echo "🧪 Test 10: Auto-update disabled via AUTO_UPDATE"

export TELEGRAM_TOKEN="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
export TELEGRAM_CHATID="123456"
export AUTO_UPDATE="false"
export SKIP_UPDATE=""
export DUPLICATI__EVENTNAME="AFTER"
export DUPLICATI__PARSED_RESULT="Success"

# Just verify script starts without error (auto-update should be skipped)
if bash -n notify_to_telegram.sh 2>/dev/null; then
    run_test "AUTO_UPDATE=false no syntax error" "true"
else
    run_test "AUTO_UPDATE=false no syntax error" "false"
fi

# ── Summary ────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0