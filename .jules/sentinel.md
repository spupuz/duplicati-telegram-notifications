## 2026-09-13 - Prevent Secret Leakage from Inherited Environment Variables
**Vulnerability:** Information Disclosure (CWE-200) occurred because sensitive environment variables (such as `DUPLICATI__passphrase` or `DUPLICATI__aws_secret_key`) inherited from the parent environment (e.g., Docker `ENV`) remained exported. These secrets could then be inadvertently exposed to the environment of all spawned child processes (such as `curl` or `grep`) and retrieved via `/proc/<pid>/environ`.
**Learning:** Even if a script does not explicitly `export` a variable, any variables inherited as exports from the parent environment remain exported.
**Prevention:** Always explicitly un-export (e.g., `export -n`) sensitive environment variables early in a script to strictly confine them to the script's internal shell environment and prevent leakage to spawned child processes.
## 2026-09-08 - Integer parsing base
**Vulnerability:** Base-8 parsing error
**Learning:** Leading zeros cause numbers to be treated as octal
**Prevention:** Use base-10 radix prefix $((10#$val))
## 2026-09-08 - Fix Symlink Arbitrary File Overwrite in Auto-Update
**Vulnerability:** The auto-update mechanism used `cp` to overwrite the script file, which is vulnerable to CWE-59 (Symlink Arbitrary File Overwrite). An attacker could place a symlink at the script path to overwrite arbitrary sensitive files when the script updates.
**Learning:** Using `cp` to replace files retains the inode and follows symlinks. It also risks `Text file busy` errors if the script is currently running.
**Prevention:** Always use `mv -f` to atomically replace executable files or files in shared paths, breaking any potential symlinks and avoiding execution locks.
## 2026-09-09 - Prevent Path Traversal in Auto-Update Ref
**Vulnerability:** A Path Traversal / Open Redirect vulnerability existed in the GitHub `auto_update` mechanism. If an attacker hijacked the HTTP redirect for the release check (e.g., via DNS spoofing or proxy), they could supply a `Location` header containing `../` in the tag portion. Because `curl`'s raw URL request resolves `../` locally, this forced the script to download and execute an arbitrary malicious payload from the attacker's repository.
**Learning:** External variables sourced from HTTP Headers (like redirects) must be strictly validated before being interpolated into file paths or network URLs.
**Prevention:** Always validate extracted values using a strict allow-list or deny-list for structural path characters (e.g., `/`, `../`) to prevent directory traversal in network requests.
## 2026-09-09 - Prevent permission collisions in cache directory
**Vulnerability:** In multi-user environments (e.g., shared CI servers), falling back to a hardcoded path like `/tmp/.cache` and creating temporary cache files without the Effective User ID (EUID) can cause permission collisions if multiple users run the script simultaneously or if directories created by one user block others.
**Learning:** Hardcoded shared hidden directories (e.g., `/tmp/.cache`) are unsafe in multi-user systems. Un-prefixed `mktemp` cache files might not clash in file names, but they clutter and violate security isolation best practices.
**Prevention:** Always append the EUID (e.g., `_${uid_cache}`) to all cache/temporary filenames and use the native `${TMPDIR:-/tmp}` directly instead of nesting a `.cache` folder within `/tmp`.
## 2026-09-10 - Prevent Path Traversal from Untrusted Cache
**Vulnerability:** A Cache Poisoning vulnerability could lead to Path Traversal and Remote Code Execution. The `latest_version` was read from a shared cache file (e.g., in `/tmp`) and interpolated into the `dl_url` without validation. If an attacker poisoned the cache with `../../../malware`, `curl` would download and the script would execute the malicious code.
**Learning:** External variables sourced from untrusted storage (like shared cache directories) must be strictly validated before being interpolated into file paths or network URLs.
**Prevention:** Always validate cached values using a strict allow-list (e.g., `*[!a-zA-Z0-9.-]*`) before using them in sensitive operations.
## 2026-09-11 - Prevent Secret Leakage to Child Processes
**Vulnerability:** Information Disclosure
**Learning:** Exporting parsed secrets (like `TELEGRAM_TOKEN`) exposes them to the environment of all child processes invoked by the script, making them retrievable via `/proc/<pid>/environ` or environment error dumps.
**Prevention:** Avoid `export` for sensitive configuration values. Only assign them to internal shell variables.
## 2026-09-12 - Prevent Silent Notification Drops (DoS)
**Vulnerability:** A localized Denial of Service (DoS) vulnerability could occur if a backup failed with a large stack trace. Unbounded variables like `RES_Failed` and `RES_Details` were sent directly to the Telegram API. If the payload exceeded Telegram's 4096-character limit, the API would return a 400 Bad Request error, causing the notification to be silently dropped.
**Learning:** External APIs often enforce strict payload limits. Sending unbounded input (like application stack traces) without truncation can lead to silent failures where critical error alerts are never received.
**Prevention:** Always truncate unbounded input using native Bash substring expansion (e.g., `${var:0:1500}`) before transmission to prevent exceeding API limits.
## 2026-09-11 - Prevent Denial of Service (DoS) via Telegram API limits
**Vulnerability:** A Denial of Service (DoS) vulnerability existed due to a lack of input length limits for backup results. If a backup produced extremely long error details (e.g., massive `.NET` stack traces) or if environment variables like `DUPLICATI__backup_name` were excessively large, the final message payload would exceed the 4096-character limit of the Telegram API. This resulted in a HTTP 400 Bad Request error from Telegram and completely dropped the notification, silently hiding critical backup failures.
**Learning:** External APIs often enforce strict payload limits. Simply passing through unconstrained input (especially stack traces or large logs) from external sources directly to these APIs can easily trigger these limits, resulting in silent notification failures (DoS).
**Prevention:** Always implement input length truncation for potentially unbounded user-controlled input or external logs before formatting and transmitting them to restricted APIs like Telegram.
## 2026-09-12 - Prevent Denial of Service (DoS) via Telegram API limits
**Vulnerability:** A Denial of Service (DoS) vulnerability existed because `DUPLICATI__EVENTNAME` and `DUPLICATI__PARSED_RESULT` were not truncated before being sent to the Telegram API. An attacker or unexpected system behavior could provide excessively long values, causing the message payload to exceed the 4096-character limit of the Telegram API, which results in a HTTP 400 Bad Request error and completely drops the notification.
**Learning:** External APIs often enforce strict payload limits. All unbounded input (including event names and parsed results) should be truncated.
**Prevention:** Always implement input length truncation for potentially unbounded user-controlled input or environment variables before formatting and transmitting them to restricted APIs like Telegram.
## 2024-05-20 - Prevent SSRF via Telegram API Credentials
**Vulnerability:** Server-Side Request Forgery (SSRF) and URL manipulation via unvalidated `TELEGRAM_TOKEN` and `TELEGRAM_CHATID` variables in shell scripts.
**Learning:** Shell variables loaded from `.env` files or environment exports might contain structural URL characters (e.g., `../`, `?`, `#`) that can alter intended API requests, particularly when directly interpolated into URLs.
**Prevention:** Always validate external API credentials and identifiers using strict regular expressions (allow-lists) before interpolating them into network request URLs.

## 2023-10-27 - Prevent SSRF via Telegram API Configuration
**Vulnerability:** A Server-Side Request Forgery (SSRF) and URL manipulation vulnerability existed because `TELEGRAM_TOKEN` and `TELEGRAM_CHATID` were not validated before being used to construct the external Telegram API URL or passed as parameters. If these values were manipulated (e.g., via compromised environment variables), they could alter the request URL or inject unintended parameters.
**Learning:** External API credentials and parameters must be strictly validated against their expected formats before being interpolated into URLs.
**Prevention:** Always validate API tokens (e.g., `^[0-9]+:[a-zA-Z0-9_-]+$`) and IDs (e.g., `^-?[0-9]+$`) using strict allow-lists or regex matching before using them in network requests.
## 2024-05-20 - Prevent Argument Injection in Command-Line Tools
**Vulnerability:** Argument Injection (CWE-88) occurred because user-controlled or environment-provided input (`DUPLICATI__RESULTFILE`) was passed directly to the `grep` command without being separated from options. If an attacker created a file named `-r` or `-V` and forced the script to parse it, `grep` would interpret the filename as a command-line flag instead of a file to read, potentially leading to information disclosure or unexpected behavior.
**Learning:** Command-line utilities (like `grep`, `rm`, `cat`) parse arguments starting with `-` as options. Passing unvalidated variables directly to these tools can lead to argument injection if the variable value begins with a hyphen.
**Prevention:** Always use the end-of-options delimiter `--` before passing untrusted variable content as positional arguments (e.g., filenames) to command-line tools to ensure they are strictly treated as operands, not flags.
## 2024-05-20 - Un-export Inherited Secrets
**Vulnerability:** Information Disclosure (CWE-200)
**Learning:** Even if secrets are assigned internally, they might have been inherited from the parent environment (e.g. Docker ENV), remaining exported to all child processes spawned by the script.
**Prevention:** Always explicitly use `export -n` on sensitive configuration variables to confine them to the internal shell environment and prevent leakage to child processes.
## 2024-05-20 - Prevent Information Disclosure via Config File Permissions
**Vulnerability:** Information Disclosure (CWE-200) could occur if a configuration file containing sensitive credentials (like `TELEGRAM_TOKEN`) was created with overly permissive file permissions (e.g., `644`), allowing other users on a shared system to read the secrets.
**Learning:** Even if a script parses credentials securely, the underlying configuration file on disk remains a target. In shared or multi-user environments, users might inadvertently create config files with default `umask` permissions that allow world-read access.
**Prevention:** Always programmatically enforce strict file permissions (e.g., `chmod 600`) before reading sensitive configuration files to guarantee that only the owner can access the credentials.
## 2024-05-20 - Prevent HTML Injection (XSS) in Auto-Update Notification
**Vulnerability:** A Cross-Site Scripting (XSS) / HTML Injection vulnerability existed because `$UPDATED_FROM_VERSION` and `$SCRIPT_VERSION` were directly interpolated into the `$MESSAGE` string sent to the Telegram API with `parse_mode=HTML`. If an attacker managed to manipulate these version variables (e.g., via a compromised GitHub repository or release tag), they could inject malicious HTML tags.
**Learning:** Even internally sourced or seemingly safe external variables like software version strings must be treated as untrusted input when formatting for rich text APIs.
**Prevention:** Always sanitize and escape variables using functions like `escapeHTML` before embedding them in HTML-formatted message payloads to prevent injection vulnerabilities.
