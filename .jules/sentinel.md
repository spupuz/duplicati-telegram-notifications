## 2024-05-15 - Symlink Arbitrary File Overwrite
**Vulnerability:** Direct file creation using `touch` on a predictable path that can fall back to `/tmp/`.
**Learning:** Using `touch` or redirection (`>`) directly on a predictable path in a shared directory allows an attacker to pre-create a symlink to an arbitrary file, causing the script to overwrite or modify the target file.
**Prevention:** Always create a temporary file securely using `mktemp` and then atomically move it to the target path using `mv -f`.
