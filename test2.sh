#!/bin/bash
func() { echo "a * b"; }
A=$(func)
echo "$A"
B+=$(func)
echo "$B"
