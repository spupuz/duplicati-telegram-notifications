## 2026-09-08 - Integer parsing base
**Vulnerability:** Base-8 parsing error
**Learning:** Leading zeros cause numbers to be treated as octal
**Prevention:** Use base-10 radix prefix $((10#$val))
## 2026-09-08 - Fix Symlink Arbitrary File Overwrite in Auto-Update
**Vulnerability:** The auto-update mechanism used `cp` to overwrite the script file, which is vulnerable to CWE-59 (Symlink Arbitrary File Overwrite). An attacker could place a symlink at the script path to overwrite arbitrary sensitive files when the script updates.
**Learning:** Using `cp` to replace files retains the inode and follows symlinks. It also risks `Text file busy` errors if the script is currently running.
**Prevention:** Always use `mv -f` to atomically replace executable files or files in shared paths, breaking any potential symlinks and avoiding execution locks.
