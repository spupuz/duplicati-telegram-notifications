## 2024-09-04 - Protocol Downgrade and DoS in Auto-Updaters
**Vulnerability:** The auto-update function used `curl` to fetch from GitHub without connection timeouts or enforcing HTTPS, making it vulnerable to protocol downgrade attacks and indefinite hangs if the API was unresponsive (a localized Denial of Service).
**Learning:** Even internal helper functions like auto-updaters need full network security controls because network timeouts can block the entire parent process (like a backup job).
**Prevention:** Always enforce secure protocols (`--proto '=https'`) and strict connection timeouts (`--connect-timeout`) on synchronous `curl` calls in shell scripts.
