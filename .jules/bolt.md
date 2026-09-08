## 2024-05-24 - Native Bash Globbing vs Regex in Loops
**Learning:** Using regex matching (`=~`) inside bash `while read` loops to validate strings is significantly slower than using native bash globbing (`!= *[!a-zA-Z0-9_]*`), because regex evaluation incurs more overhead per iteration. This becomes a bottleneck when parsing large files like Duplicati result logs.
**Action:** Always prefer native bash globbing (e.g., `[[ -n "$var" && "$var" != *[!a-zA-Z0-9_]* && "$var" != [0-9]* ]]` for valid identifier check) over regex in loops where performance matters.
