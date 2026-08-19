#!/bin/bash
val="<"
val="${val//</&lt;}"
echo "1: $val"

val="<"
val="${val//</\&lt;}"
echo "2: $val"

val="<"
val="${val//</&amp;lt;}"
echo "3: $val"

val="&"
val="${val//&/&amp;}"
echo "4: $val"
