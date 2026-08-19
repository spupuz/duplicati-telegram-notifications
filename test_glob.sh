#!/bin/bash
touch glob_1 glob_2
func() { echo "*"; }
VAR=$(func)
echo "$VAR"
VAR+=$(func)
echo "$VAR"
