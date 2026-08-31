## 2024-05-18 - Parameter Injection via curl
**Vulnerability:** The curl command used to send Telegram notifications passed variables (like `chat_id` and `parse_mode`) using the `-d` flag. This left the system vulnerable to HTTP Parameter Injection, as unsanitized variables containing special characters (like `&`) could inject arbitrary parameters into the API request.
**Learning:** Even internal or configuration-based variables passed to curl need to be URL encoded if they are part of a URL-encoded request body.
**Prevention:** Always use `--data-urlencode` instead of `-d` when sending payload parameters with curl to external APIs to guarantee all special characters are properly escaped and treated as values rather than control characters.
