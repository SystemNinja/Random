#!/bin/bash

#####################################################################
# Here is a function which you can use for debugging process in bash.
# Uncomment "# exit ${EXIT_CODE}" if you want script to exit when 
# exit code is not 0
# -------------------------------------------------------------------
# Author: Darko Drazovic | Kompjuteras.com
# Date  : 28/08/2018
#####################################################################

isok () {
 EXIT_CODE=$?
 if [[ ${EXIT_CODE} -ne 0 ]]
   then
        echo "PROBLEM: Exit code ($EXIT_CODE) at line: $(echo ${BASH_LINENO[*]} | awk '{print $1 - 1}' )"
        # exit ${EXIT_CODE}
   else
        echo "OK: Everything is fine at line: $(echo ${BASH_LINENO[*]} | awk '{print $1 - 1}')"
 fi
}

# Uncomment next lines if you want to test this function
# cat /dadadafafaf &> /dev/null # Line 24
# isok
#
# cat /dev/null &> /dev/null # Line 27
# isok
