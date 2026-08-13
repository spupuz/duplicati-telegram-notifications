## 2023-10-24 - [Fix command injection via `eval` parsing]
**Vulnerability:** The `notify_to_telegram.sh` script used `eval $(sed ...)` to dynamically parse variables from a log file (`$DUPLICATI__RESULTFILE`). This allowed command injection if a maliciously crafted file contained values like `$(rm -rf /)`.
**Learning:** `eval` is extremely dangerous when parsing external files or logs. Even if the expected format is simple key-value pairs, an attacker can exploit string values executed inside `eval`.
**Prevention:** Avoid `eval` for parsing configurations or text files. Use safer alternatives like `while IFS=':' read -r key val` and dynamic variable assignment via `printf -v "$key" "%s" "$val"` while enforcing strict regex validation for keys.
