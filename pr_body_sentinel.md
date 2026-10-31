## Vulnerability

The script stripped `TELEGRAM_TOKEN`, `TELEGRAM_CHATID`, and `TELEGRAM_URL` from the environment (line 118) to prevent credential leakage to child processes via `/proc/<pid>/environ`.

However, line 224 **re-exported** these three variables before the `exec` self-reexec path in `auto_update()`. On a self-reexec (auto-update), this re-introduced credentials into the process environment.

This is especially dangerous because:
- Container installations inherit `TELEGRAM_TOKEN`/`TELEGRAM_CHATID` from Docker ENV — they are already present; re-exporting is redundant
- Config-file installs have already reloaded them from file after strip, so re-export is unnecessary
- The re-export defeats the leak-prevention fix for any spawned children (curl, grep)

## Impact

Credential disclosure in system process lists — compromised machines can read token/chat ID from `/proc/<pid>/environ`.

## Fix

Removed the top-level re-export of credentials. They remain available for `auto_update()`'s internal use (it constructs `TELEGRAM_URL`) and for self-reexec's parent shell, but no longer leak to the immediately-spawned child `exec "$SCRIPT_PATH" "$@"`. After self-reexec, the new shell reloads credentials from config if available.

## Verification

- bash -n passes
- test_notify.sh passes
- No behavioral regression: self-update path unchanged, notifications still sent

Created by authenticated GitHub account @spupuz.
