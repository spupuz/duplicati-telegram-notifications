#!/bin/bash
sanitize_html() {
    local val="$1"
    # First replace & with &amp;
    val="${val//&/&amp;}"
    # Replace < with &lt; (need to escape & in replacement)
    val="${val//</\&lt;}"
    # Replace > with &gt; (need to escape & in replacement)
    val="${val//>/\&gt;}"
    echo "$val"
}

echo $(sanitize_html "Backup <Critical> & Data")
