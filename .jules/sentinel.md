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

## 2026-08-20 - Environment Variable Injection via Dynamic Variable Assignment
**Vulnerability:** In `notify_to_telegram.sh`, the `parseResultFile` function read keys and values from a result file and dynamically assigned them to bash variables using `printf -v "$key" "%s" "$val"`. Because `$key` was taken directly from the file content (which could be influenced by external input or manipulated), an attacker could overwrite critical shell variables (like `PATH`, `TELEGRAM_TOKEN`, or `TELEGRAM_URL`), potentially leading to local privilege escalation or arbitrary code execution.
**Learning:** Dynamic variable assignment using untrusted input is dangerous in bash, as it shares the same namespace as environment and internal shell variables.
**Prevention:** Always namespace dynamically generated variables (e.g., prefixing them with `RES_`) to prevent collision with system or script-critical variables, or use associative arrays if the bash version supports them.

## 2024-05-24 - Information Disclosure via Globbing in Subshells
**Vulnerability:** The script suffered from an information disclosure vulnerability due to unquoted variables within command substitutions (e.g., `$(printf %7s $RES_AddedFiles)`). If an attacker could inject shell globbing characters (like `*` or `?`) into the parsed log variables, the shell would expand them to match files in the current directory before passing them to `printf`. This would leak the contents of the directory (filenames) into the notification payload.
**Learning:** Variables used inside command substitutions (`$(...)`) are still subject to word splitting and pathname expansion (globbing) by the shell if they are unquoted. This is a common pitfall that can lead to unexpected behavior and security issues.
**Prevention:** Always quote variables, especially when passing them as arguments to commands or inside command substitutions. For example, use `$(printf "%7s" "$RES_AddedFiles")` instead of `$(printf %7s $RES_AddedFiles)`.

## 2026-08-20 - [HTML Injection in Telegram Notifications]
**Vulnerability:** User-controlled input (like backup name, error details) was sent unescaped to the Telegram API with `parse_mode="HTML"`.
**Learning:** If user-controlled input contains unescaped HTML characters (`<`, `>`, `&`), it causes a 400 Bad Request error from the Telegram API, leading to silent notification failures (Denial of Service).
**Prevention:** Always escape HTML characters (`&`, `<`, `>`) in variables that are embedded into Telegram HTML messages.
