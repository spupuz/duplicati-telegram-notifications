
## 2026-08-29 - [Synchronous Network Requests Block Micro-Optimizations]
**Learning:** Checking for updates synchronously over the network (`curl -s ...`) on every execution of a bash script introduces significant, blocking overhead (100ms - 5000ms). This entirely negates the 1-5ms savings from avoiding fork/exec subshells (like replacing `tr` or `awk` with native bash).
**Action:** Always cache the results of non-critical external network requests in temporary files (e.g., checking `find ... -mmin -1440` for 24-hour validity) to eliminate network latency on subsequent runs and preserve micro-optimization benefits.
