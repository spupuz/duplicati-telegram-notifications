#!/bin/bash
function test_func() {
  echo "Hello *"
}
MESSAGE="Start "
MESSAGE+=$(test_func)
echo "$MESSAGE"
