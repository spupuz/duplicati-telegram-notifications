## 2026-09-02 - Early Exit Optimizes Skipped Operations
**Learning:** Early exit conditions (like skipping "List" operations) should be placed at the very top of the script, before any environment loading, parsing, or network requests. Leaving it later in the script forces unnecessary and potentially expensive operations (like GitHub API auto-update checks) for operations that will be discarded anyway.
**Action:** Always scan for short-circuit conditions and move them as early in the execution path as possible to avoid redundant work and network calls.
