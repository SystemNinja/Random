#!/bin/bash

###################################################################################
# Here are some functions which you can use in your shell scripts for some checks 
# or what ever. I put as a comment ##### on all exit commands, so you are free
# to modify these functions how ever you like. 
# Please, before use on any production environments test first everything on test
# servers. These functions here are tested on CentOS 7 and CentOS 6 minimal Linux.
# Functions will be updated from time to time...
# ---------------------------------------------------------------------------------
# Author: Darko Drazovic | Kompjuteras.com
# ---------------------------------------------------------------------------------
####################################################################################


# Echo Separator in reports. 
# Usage example: SEP
function SEP () {
  echo "---------------------------------------------------------------------------"
}


# Check exit code and if there is no normal exit (exit code is no 0) then print 
# error message, line number where did exit code is shown and exit code
# I think this is a very good function for debugging in the shell which you write
# Usage example: ISOK
function ISOK () {
  EXIT_CODE=$?
    if [[ ${EXIT_CODE} -ne 0 ]]
      then
        echo "PROBLEM : Exit code ($EXIT_CODE) at line: $(echo ${BASH_LINENO[*]} | awk '{print $1 - 1}' )"
		##### exit ${EXIT_CODE}
      else 
        echo "INFO    : Everything is OK at line: $(echo ${BASH_LINENO[*]} | awk '{print $1 - 1}' )"
    fi
}


# Just print line number, nothing else.
# It can be useful for debugging in bash scripting
# Usage example: LNNO
function LNNO () 
{
  echo "INFO    : Line number $(echo ${BASH_LINENO[*]} | awk '{print $1}')"
}


# Check is there enough free space on path which you provide. Please enter
# path and percentage of safe space
# Usage example: CHECK_DISKSPACE_ON /boot 80% (if on /boot is used more than 80% print a warning)
# Usage example: CHECK_DISKSPACE_ON /boot 80  (same as previos)
# Usage example: CHECK_DISKSPACE_ON /boot     (just show me used space on /boot)
function CHECK_DISKSPACE_ON () {
  WHERE=$1
  MAXIMUM=$2
  # Do you have (minimum) 1 input parameter (path)
  if [[ $# -lt 1 ]]
    then
	  echo "Usage example: \"CHECK_DISKSPACE_ON /var/log\" or \"CHECK_DISKSPACE_ON /var/log 80%\""
	  ##### exit 0
  fi

  # Does provided path exists
  if [[ -z "$(find ${WHERE} 2> /dev/null)" ]]
    then
	  echo "PROBLEM : Folder of file path ${WHERE} dont exists"
	  ##### exit 0
  fi

  # If maximum percentage of used space is not defined, put 100%
  if [[ -z $MAXIMUM ]] ; then MAXIMUM=100 ; fi
	
  # Is number is in second parameter
  if [[ $(echo $MAXIMUM | grep -o [0-9]* | wc -l) -ne 1 ]]
    then
	  echo "WARNING: What is this --> ${MAXIMUM}"
	  ##### exit 0
  fi
  # Check
  CURENTLY_USED="$(df -hP ${WHERE} | tail -n +2 | awk '{print $5}' | grep -o [0-9]*)"
  REAL_PATH="$(df -hP ${WHERE} | tail -n +2 | awk '{print $6}')"
    if [[ ${CURENTLY_USED} -gt "$(echo $MAXIMUM | grep -o [0-9]*)" ]]
      then
	    echo "PROBLEM : On path \"${REAL_PATH}\" where is located folder ${WHERE}: ${CURENTLY_USED}% is space used" 
		##### exit 1
      else
	    echo "INFO    : There is ${CURENTLY_USED}% space on \"${REAL_PATH}\" where is located folder \"${WHERE}\""
    fi
}


# Check free space on all partition. If there is no input parameter it will
# show usage from all disks as a info. If you put as a 
# Usage example: CHECK_DISKSPACE     (show info about usage on all disks)
# Usage example: CHECK_DISKSPACE 90  (print all disks where is used more than 90% of space)
# Usage example: CHECK_DISKSPACE 90% (the same as the previous example)
function CHECK_DISKSPACE () {
  MAXIMUM=$(echo $1 | grep -o [0-9]*)
    # If no input paramteter, put zero
    if [[ -z $MAXIMUM ]] ; then MAXIMUM=0 ; fi

    for i in $(df -hP | grep '^/' | awk '{print $1}' | xargs)
    do
      PARTITION=$i
      MOUNT_POINT=$(df -hP $i | awk '{print $6}' | tail -1)
      USAGE=$(df -hP $i | awk '{print $5}' | grep -o [0-9]*)
        if [[ ${USAGE} -gt ${MAXIMUM} ]]
          then 
            echo "PROBLEM : ${USAGE}% used space on \"$PARTITION\" mounted on \"${MOUNT_POINT}\""
			##### exit 1
		  else
		    echo "INFO    : ${USAGE}% used space on \"$PARTITION\" mounted on \"${MOUNT_POINT}\""
        fi
    done
}


# Check does folder, file or symlink exists.
# Usage example: DOES_PATH_EXISTS /home/some-folder
function DOES_PATH_EXISTS () {
  FOLDER_OR_FILE_PATH=$1
    if [[ -z "$(find $FOLDER_OR_FILE_PATH 2> /dev/null)" ]]
    then
	  echo "PROBLEM : Folder of file $FOLDER_OR_FILE_PATH doesn't exists"
	  ##### exit 1
    else
	  echo "INFO    : Folder of file $FOLDER_OR_FILE_PATH is present"
    fi
}


# Does mountpoint exists now
# Usage example: CHECK_MOUNTPOINT /boot
function CHECK_MOUNTPOINT () {
  MOUNT_POINT="$(mount | grep $1)"
    if [[ -z $MOUNT_POINT ]]
      then
	    echo "PROBLEM : I don't see mountpoint: $*"
		##### exit 1
	  else
	    echo "INFO    : Mount point \"$1\" exists"
    fi
}

# Check current user, useful for a script where the particular user is needed for a script execution
# Usage example: DID_SCRIPT_RUN_BY oracle
function DID_SCRIPT_RUN_BY () {
  if [[ $# -ne 1 ]]
    then 
      echo "Usage example: DID_SCRIPT_RUN_BY oracle"
      ##### exit 1
  fi

  NEEDED_USER="$1"
	if [[ $(whoami) != ${NEEDED_USER} ]]
	  then
        echo "PROBLEM : Please run this script as a user: ${NEEDED_USER}"
        ##### exit 1
	  else
	    echo "INFO    : Script is execute by user ${NEEDED_USER}"
	fi
}

# Whow all unpartitioned disks in the system, which can be candidates (for example) for LVM
# Usage example: CHECK_UNPARTIONED_DISKS
function CHECK_UNPARTIONED_DISKS () {
  existing_HDDs="$(fdisk -l | grep -i disk | grep -v 'identifier\|mapper\|label' | cut -d ':' -f 1 | cut -d ' ' -f 2 | xargs)"
    for disk in ${existing_HDDs}
    do
      DISK=$disk
        if [[ $(lsblk $disk | wc -l) -eq 2 ]] ; then
          KANDIDAT+="$disk "
        fi
    done

  if [[ ! -z $KANDIDAT ]]
    then
      echo "INFO    : Unpartitioned disk(s): "$KANDIDAT
    else
      echo "INFO    : No unpartitioned disks here"
fi
}


# Show current load in the system. If there are no input parameters then as a referent
# value use number of CPU's.
# Usage example: CHECK_CURRENT_LOAD (if the load is bigger than CPU number, print info)
# Usage example: CHECK_CURRENT_LOAD 2 (if the load is bigger than 2, print warning)

function CHECK_CURRENT_LOAD () {
  CURRENT_LOAD="$(cat /proc/loadavg | awk '{print $1}')"
  MAXIMUM=$1
    if [[ -z $MAXIMUM ]]
      then MAXIMUM="$(cat /proc/cpuinfo | grep vendor_id | wc -l)"
    fi

	# Function from StackOverflow :)
    numCompare() {
      awk -v n1="$CURRENT_LOAD" -v n2="$MAXIMUM" 'BEGIN {printf "%s " (n1<n2?"<":">=") " %s\n", n1, n2}'
    }

	# Check
    if [[ $(echo $(numCompare $CURRENT_LOAD $MAXIMUM) | grep '>' | wc -l) -gt 0 ]] 
      then
        echo "PROBLEM : Current load is $CURRENT_LOAD (of max $MAXIMUM)"
		##### exit 1
      else
        echo "INFO    : Current load is $CURRENT_LOAD (of max $MAXIMUM)"
    fi
}

# Test examples....
SEP
ISOK
cat /undefined_file &> /dev/null
ISOK
LNNO
CHECK_DISKSPACE_ON /boot
CHECK_DISKSPACE_ON /boot 10%
CHECK_DISKSPACE_ON /boot 90%
CHECK_DISKSPACE
CHECK_DISKSPACE 10
CHECK_DISKSPACE 90
DOES_PATH_EXISTS /home 
DOES_PATH_EXISTS /home/unknown-folder
CHECK_MOUNTPOINT /boot
CHECK_MOUNTPOINT /boot_unknown
DID_SCRIPT_RUN_BY root
DID_SCRIPT_RUN_BY oracle
CHECK_UNPARTIONED_DISKS
CHECK_CURRENT_LOAD
CHECK_CURRENT_LOAD 5
CHECK_CURRENT_LOAD 0
SEP

echo "To be continued....."
