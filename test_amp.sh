#!/bin/bash
val="<"
val="${val//</&lt;}"
echo "$val"
