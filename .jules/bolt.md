## 2024-09-13 - Early exit condition in large bash file parsing loop
**Learning:** When parsing large log/result files with `while read` loops in Bash, placing an early exit (short-circuit) condition at the very top of the loop to skip native string operations on unmatched lines saves substantial CPU time and script duration.
**Action:** Always include an early short-circuit (e.g., `[[ -z "$val" ]] && continue` when delimiting by colon) inside large log parsing loops before applying string manipulation variables to eliminate overhead on unmatched formatting.
