#!/bin/bash
touch test_file_1 test_file_2
func() { echo "*"; }
A=$(func)
echo "$A"
B+=$(func)
echo "$B"
