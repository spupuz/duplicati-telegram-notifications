
## 2024-09-14 - Short-circuit string parsing in bash loops
**Learning:** When parsing log files or structured outputs in Bash using `while IFS=':' read` loops, processing free-text lines (like stack traces) that don't match the delimiter format incurs significant CPU overhead because Bash still runs all subsequent string manipulations (like `${val#...}`) on the entire line.
**Action:** Always place an early exit (short-circuit) condition (e.g., `[[ -z "$val" ]] && continue`) at the very top of the parsing loop to skip lines that do not match the expected structure, saving CPU cycles.
