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
