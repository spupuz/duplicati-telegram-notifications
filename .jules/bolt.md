## 2024-08-11 - Replaced expensive subshells with native Bash case statements
**Learning:** Native string manipulation and mapping in Bash (using `case`) is substantially faster (~1000x) than spawning subshells to call external binaries like `echo` piped to `sed`. Additionally, `sed` with fallback logic fails when input is not explicitly captured by regex unless complex logic is provided, whereas a `case` fallback is robust and explicit.
**Action:** Always favor native bash constructs (`case`, parameter expansion) over spawning child processes (`sed`, `awk`, `grep`) for simple string manipulation and variable assignments within scripts executing rapidly or multiple times.

## 2024-11-20 - Native Bash integer math vs awk subshells
**Learning:** Shelling out to tools like `awk` for floating-point calculations within a function called multiple times per run introduces significant `fork`/`exec` overhead. Native bash integer arithmetic (e.g., `$(( (size * 100 / divisor + 5) / 10 ))` for decimal representation) is orders of magnitude faster (e.g., 6ms vs 344ms for 100 iterations).
**Action:** Use scaled native integer arithmetic for simple decimal calculations instead of spawning external binaries like `awk` or `bc` in frequently executed bash functions.
