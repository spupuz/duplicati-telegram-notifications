## 2024-05-15 - [Critical] Fix HTML Escaping and Asynchronous Alert Drop
**Vulnerability:** The `escapeHTML` function was malfunctioning due to incorrect quote usage and the introduction of `patsub_replacement` in Bash 5.2. Furthermore, critical security alerts were being sent via an asynchronous `curl` command `(curl ... &)`, leading to silently dropped notifications in ephemeral environments.
**Learning:**
1. In Bash parameter expansion `${var//pattern/replacement}`, quotes in the replacement string are treated literally. `&` has a special meaning in Bash 5.2+ (referencing the matched substring) when `patsub_replacement` is enabled, which broke HTML escaping.
2. In ephemeral environments (like Docker containers where Duplicati might run), running network requests asynchronously causes the parent process to exit before the request completes, dropping alerts.
**Prevention:**
1. Do not use quotes around replacement strings in parameter expansions. Use `shopt -u patsub_replacement 2>/dev/null || true` before literal string replacements involving `&`.
2. Ensure critical network alerts (`curl`) run synchronously in shell scripts to guarantee delivery.
