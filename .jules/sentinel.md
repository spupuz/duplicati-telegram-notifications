## 2023-10-27 - Missing Timeout in Synchronous Backup Hook
**Vulnerability:** The final `curl` call to the Telegram API lacked timeout configurations.
**Learning:** Because this script is run synchronously by Duplicati, an unresponsive external API or blackholed network route causes `curl` to hang indefinitely. This blocks the entire Duplicati backup process, preventing current and future backups from executing (a local DoS).
**Prevention:** Always add `--connect-timeout` and `--max-time` to network requests (e.g. `curl`) within synchronous hooks. Also use `--proto '=https'` to prevent protocol downgrade attacks.
