## 2024-08-11 - Replaced expensive subshells with native Bash case statements
**Learning:** Native string manipulation and mapping in Bash (using `case`) is substantially faster (~1000x) than spawning subshells to call external binaries like `echo` piped to `sed`. Additionally, `sed` with fallback logic fails when input is not explicitly captured by regex unless complex logic is provided, whereas a `case` fallback is robust and explicit.
**Action:** Always favor native bash constructs (`case`, parameter expansion) over spawning child processes (`sed`, `awk`, `grep`) for simple string manipulation and variable assignments within scripts executing rapidly or multiple times.

## 2024-08-11 - Replaced awk subshells with native Bash arithmetic for size formatting
**Learning:** Formatting file sizes with multiple calls to `awk` spawns child processes repeatedly, which is highly inefficient for scripts processing numerous values (like an operation summary). Pure Bash arithmetic `val=$(( (size * 100 / divisor + 5) / 10 )); echo "$((val / 10)).$((val % 10))"` can achieve the equivalent of `awk 'BEGIN {printf "%.1f",...}'` with 1-decimal rounding in ~1/100th of the time without spawning any extra processes.
**Action:** Use native bash arithmetic and formatting tricks for simple math and formatting, especially in formatting functions called inside output generators, to minimize fork/exec overhead.

## 2024-08-17 - Eliminating Subshell Pipelines and Redundant I/O
**Learning:** The script repeatedly read the same result file (`parseResultFile`) inside different functions and used an expensive child process pipeline (`grep | sed | tr`) to extract the backup duration. By hoisting the file read to the top of the event block and using native Bash parameter expansion (`${Duration%%.*}`), we eliminate multiple subshells/forks and redundant disk I/O.
**Action:** Look for duplicate file reading and replace standard Unix text processing tools (grep/sed/tr/awk) with native Bash built-ins whenever performing simple string extraction.
