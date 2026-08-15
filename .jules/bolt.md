## 2024-08-11 - Replaced expensive subshells with native Bash case statements
**Learning:** Native string manipulation and mapping in Bash (using `case`) is substantially faster (~1000x) than spawning subshells to call external binaries like `echo` piped to `sed`. Additionally, `sed` with fallback logic fails when input is not explicitly captured by regex unless complex logic is provided, whereas a `case` fallback is robust and explicit.
**Action:** Always favor native bash constructs (`case`, parameter expansion) over spawning child processes (`sed`, `awk`, `grep`) for simple string manipulation and variable assignments within scripts executing rapidly or multiple times.

## 2024-08-15 - [Avoid Awk subshells for simple math]
**Learning:** In Bash scripts handling repeated tasks (like formatting file sizes multiple times per notification), spawning external processes like `awk` causes significant fork/exec overhead. Native Bash arithmetic can replace simple float formatting by scaling numbers up, doing integer math with rounding, and placing a decimal point in the output string.
**Action:** Replace `awk` math with scaled native bash arithmetic `$(( (val * 100 / div + 5) / 10 ))` to drastically reduce script execution time.
