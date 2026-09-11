## 2024-11-13 - Eliminate `dirname` and `basename` subshell overhead
**Learning:** In Bash, spawning child processes in subshells (e.g., using `$(dirname ...)` and `$(basename ...)`) incurs significant fork/exec overhead. This is especially noticeable for operations that execute on every run, such as locating the script directory at the very beginning of the script.
**Action:** Replace `$(dirname "$BASH_SOURCE")` and `$(basename "$BASH_SOURCE")` with native Bash parameter expansion `${BASH_SOURCE%/*}` and `${BASH_SOURCE##*/}` respectively to eliminate the fork/exec overhead.
