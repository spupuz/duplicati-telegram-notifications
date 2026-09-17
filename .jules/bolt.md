
## 2024-09-17 - Strict grep pre-filtering for read loops
**Learning:** Even when using `grep` to pre-filter input for a `while read` loop, you must make the `grep` pattern as strict as possible (e.g. matching the *exact* expected variable structure) to avoid flooding bash with unparseable log lines like timestamped entries. A generic `grep ":"` still lets thousands of irrelevant lines into the slow bash loop.
**Action:** Always pre-filter loop inputs with the most restrictive regex possible in C-binaries like `grep` to completely shield native bash string manipulation from irrelevant log output.
