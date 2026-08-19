#!/bin/bash
MESSAGE="<b>Error:</b> Backup <important> failed."
# telegram doesn't allow invalid tags
# We can't actually call telegram API without token, but we can verify it.
echo "$MESSAGE"
