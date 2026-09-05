## 2024-05-18 - First entry
## 2024-05-18 - Avoid redundant network timeout penalties with negative caching
**Learning:** During network outages or GitHub rate limits, the `curl` calls in the auto-update checker can block for up to 10 seconds due to timeouts. This happens on *every* run because failures were not cached, severely delaying critical backup processes.
**Action:** Always implement negative caching for non-essential network operations (like updates). If a network request times out or fails, cache the failure and skip the check for a reasonable backoff period to prevent repeated blocking delays on subsequent runs.
