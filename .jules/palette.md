## 2024-09-18 - Clickable Notification Tags
**Learning:** Users often struggle to search long chat histories of notifications; leveraging native platform features like hashtags drastically improves filterability and UX.
**Action:** Always consider using native platform filtering mechanics (like hashtags) when designing notification structures for chat apps.

## 2024-09-19 - Screen Reader File Size Pronunciation
**Learning:** Screen readers often mispronounce incorrectly cased or unspaced file size units (e.g., "Mb" as "Megabits" instead of "Megabytes", or reading them as a single unrecognized word).
**Action:** Always use a space between the number and the unit, and use standard uppercase abbreviations (e.g., " MB", " KB") for bytes to ensure accurate accessibility parsing.

## 2024-09-18 - Screen Reader Pronunciation of File Sizes
**Learning:** Screen readers mispronounce file sizes when the number and unit are concatenated (e.g., "1.5Mb") or when using mixed-case abbreviations (like "Mb" instead of "MB" for megabytes). This can cause confusion, such as reading "Mb" as "megabits" or an unrecognized word instead of "megabytes."
**Action:** Always format file sizes with a space between the numeric value and the unit, and use standard uppercase abbreviations (e.g., "1.5 MB"). This ensures that screen readers pronounce them correctly as bytes.

## 2024-09-21 - Explicit Zero Values for Screen Readers
**Learning:** Using dashes (`-`), blank spaces, or symbol placeholders (`--:--:--`) for zero-value data causes screen readers to either skip the value or read confusing literal symbols (like "dash" or "colon"). This lacks context for users relying on audio feedback.
**Action:** Always explicitly render numerical zero values (e.g., `0` instead of blank, `0 B` instead of `-`, and `00:00:00` instead of `--:--:--`) to ensure screen readers announce the exact state clearly and provide visual consistency in tabular layouts.
