## 2024-08-11 - Replaced expensive subshells with native Bash case statements
**Learning:** Native string manipulation and mapping in Bash (using `case`) is substantially faster (~1000x) than spawning subshells to call external binaries like `echo` piped to `sed`. Additionally, `sed` with fallback logic fails when input is not explicitly captured by regex unless complex logic is provided, whereas a `case` fallback is robust and explicit.
**Action:** Always favor native bash constructs (`case`, parameter expansion) over spawning child processes (`sed`, `awk`, `grep`) for simple string manipulation and variable assignments within scripts executing rapidly or multiple times.

## 2024-08-11 - Replaced awk subshells with native Bash arithmetic for size formatting
**Learning:** Formatting file sizes with multiple calls to `awk` spawns child processes repeatedly, which is highly inefficient for scripts processing numerous values (like an operation summary). Pure Bash arithmetic `val=$(( (size * 100 / divisor + 5) / 10 )); echo "$((val / 10)).$((val % 10))"` can achieve the equivalent of `awk 'BEGIN {printf "%.1f",...}'` with 1-decimal rounding in ~1/100th of the time without spawning any extra processes.
**Action:** Use native bash arithmetic and formatting tricks for simple math and formatting, especially in formatting functions called inside output generators, to minimize fork/exec overhead.

## 2024-08-17 - Eliminating Subshell Pipelines and Redundant I/O
**Learning:** The script repeatedly read the same result file (`parseResultFile`) inside different functions and used an expensive child process pipeline (`grep | sed | tr`) to extract the backup duration. By hoisting the file read to the top of the event block and using native Bash parameter expansion (`${Duration%%.*}`), we eliminate multiple subshells/forks and redundant disk I/O.
**Action:** Look for duplicate file reading and replace standard Unix text processing tools (grep/sed/tr/awk) with native Bash built-ins whenever performing simple string extraction.

## 2024-08-18 - Eliminated Subshells and Pipelines for String Generation
**Learning:** Building complex multi-line strings using `echo "$output" | sed` pipelines to strip whitespace, or embedding `$(printf)` and `$(custom_function)` subshells inside string definitions introduces severe performance penalties due to constant fork/exec overhead. By allowing helper functions to accept an output reference variable (`printf -v "$var"`) and using native `printf -v` to format the entire block, we can bypass all these subshells and pipelines, leading to a massive (over 90%) speedup in string generation with identical results.
**Action:** Always prefer native bash variable assignments and `printf -v` over subshells and pipes for formatting strings. Allow output helper functions to assign directly to referenced variables instead of echoing when output is captured inside frequent loops or calls.

## 2024-10-25 - Native Bash multiline string trimming
**Learning:** Replaced `echo "$output" | sed 's/^[ \t]*//;s/[ \t]*$//'` subshells/pipelines with a pure bash implementation. While simple bash variable replacement isn't great for multiline strings, looping over `while IFS= read -r line; do ... done <<< "$string"` and applying `line="${line#"${line%%[![:blank:]]*}"}"` is almost 3x faster than invoking `sed` via a pipe, saving multiple subshells and fork/exec per call. Combining this with reference variables `printf -v` completely removes the massive subshell pipeline overhead.
**Action:** When trimming multiline strings in performance-critical bash paths, favor native string extraction mechanisms inside loops over spawning text-processing binaries like `sed`.

## 2026-08-21 - Asynchronous Network Requests for Fire-and-Forget Notifications
**Learning:** Network operations like `curl` to external APIs (e.g., Telegram) can incur significant latency and block the parent process from proceeding or cleanly exiting. For fire-and-forget scripts run as hooks (like Duplicati's run-script-before/after), this blocks the main application needlessly. Wrapping the operation in a detached subshell `(curl ... >/dev/null 2>&1 &)` makes it asynchronous, freeing the parent application immediately while the network request completes in the background.
**Action:** For fire-and-forget notifications or webhooks in shell scripts where the result is not strictly necessary for the caller, execute network requests asynchronously in a detached background process to prevent blocking the caller with network I/O latency.
