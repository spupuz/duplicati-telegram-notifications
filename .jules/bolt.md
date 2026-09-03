## 2024-05-24 - Deferring Blocking Operations in Pre-Execution Hooks
**Learning:** Pre-execution hooks (like Duplicati's BEFORE event) block the primary task until they complete. Synchronous network requests (e.g., auto-update checks) in these hooks can significantly delay the start of the core operation due to network latency, even if the request is small.
**Action:** When designing pre-execution scripts, unconditionally defer all non-essential blocking network operations (like updates or telemetry) to post-execution hooks (AFTER events) to ensure the core task starts as quickly as possible.
