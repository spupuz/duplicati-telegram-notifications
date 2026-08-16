## 2024-05-24 - Command Injection in log parsing using eval
**Vulnerability:** The script parsed log files by using `eval` on the output of a `sed` command (`eval \`sed -n "s/^\(\w*\):\s*\([^\"]*\)$/\1=\"\2\"/p" $DUPLICATI__RESULTFILE\``). This meant that if an attacker could control the contents of the Duplicati log file (e.g. by generating a specific error message), they could include backticks or `$(...)` execution syntax, resulting in arbitrary shell command execution when the `eval` statement ran.
**Learning:** `eval` is extremely dangerous when parsing external files, including log files, as their contents cannot be entirely trusted. Even standard text files from other applications might contain characters that the shell interprets maliciously during `eval`.
**Prevention:** Avoid `eval`. Instead, use a secure shell `while read` loop structure to parse key-value pairs from files. Use `printf -v "$key" "%s" "$val"` for safe dynamic variable assignment, ensuring only expected variable names are populated by validating the key against a strict regex (e.g., `^[a-zA-Z_][a-zA-Z0-9_]*$`).

## 2024-05-24 - Improper Certificate Validation (CWE-295) in Telegram API Request
**Vulnerability:** The script uses `curl -k` (or `--insecure`) when making requests to the Telegram API to send backup notifications.
**Learning:** Using `-k` disables SSL/TLS certificate validation. This exposes the request to Man-in-the-Middle (MITM) attacks. An attacker on the network path could intercept the traffic, read the sensitive `TELEGRAM_TOKEN`, and view backup details (filenames, sizes, statuses).
**Prevention:** Always rely on default SSL/TLS certificate verification in tools like `curl`. Only use `-k` for explicitly documented, trusted self-signed endpoints if absolutely necessary, and never for public APIs like Telegram.

## 2026-08-16 - Prevent Parameter Injection in Telegram Notification Script
**Vulnerability:** Parameter injection in curl request to Telegram API.
**Learning:** The script constructed the curl payload using `-d text="$MESSAGE"`. If the backup information (e.g. backup name or parsed results) contained characters like `&` and `=`, an attacker could inject arbitrary parameters into the API request (such as `chat_id=ATTACKER_ID`), potentially redirecting notifications or manipulating the API call.
**Prevention:** Always URL-encode untrusted data before passing it to cURL as POST data. Use `--data-urlencode "text=$MESSAGE"` instead of `-d text="$MESSAGE"`.
