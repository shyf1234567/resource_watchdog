#!/bin/sh

# Note: this is a test shell script for study use
# Author: Yufeng Shao
# Position: developing engineer intern at Infosec(Beijing), 
# Reference: http://blog.51cto.com/yangrong/1414345
# Date: Aug 30, 2018

printHelp()
{
    cat <<HELP
    This program is a watchdog for system resource. After the user enters thresholds for cpu usage and memory usage, repectively, followed by the name of a program, the script will print the current system usage, and whether or not the program has occupied more resources than customized thresholds.
    
    USAGE:
        resource_watchdog.sh [cpu_max_usage] [memory_max_usage] [program name]
        NOTE: both thresholds should be an integer in [1-100].
    
    EXAMPLE:
        resource_watchdog.sh 50 60 sh
        
HELP
    exit 1
}

checkParam()
{
    expr 0 + "$1"&>/dev/null
    if [ $? -ne 0 ] ; then
        echo -e "resource_watchdog: invalid parameter\n"
        printHelp
    fi
    
    if [ "$1" -lt 1 ] ; then
        echo -e "resource_watchdog: out-of-range parameter\n"
        printHelp
    fi
    
    if [ "$1" -gt 100 ] ; then
        echo -e "resource_watchdog: out-of-range parameter\n"
        printHelp
    fi
    
}

# if #input parameters != 3, print help doc
if [ $# -ne 3 ] ; then
    echo -e "resource_watchdog: need 3 parameters\n"
    printHelp
fi

# get the parameters
CPU_THRES="$1";
MEM_THRES="$2";
PROG="$3";

# check if the parameters are valid
checkParam "$CPU_THRES"
checkParam "$MEM_THRES"

# get a list of (program, ..., cpu_usage, mem_usage)
PROG_CNT=`top -b -n1 | grep -c $PROG`
PROG_LIST=`top -b -n1 | grep --color $PROG`

# check if the program exists, or if the name is ambiguous
if [ $PROG_CNT -lt 1 ] ; then
	echo "resource_watchdog: program doesn't exist"
	exit 2
fi
if [ $PROG_CNT -gt 1 ] ; then
	echo "resource_watchdog: more than one program found with name [ $PROG ]:"
	echo -e "$PROG_LIST"
	echo "Please choose the correct name and retry."
	exit 2
fi

# print the current usage
echo "Now showing the program usage:"
echo "$PROG_LIST"

# check if the program occupies resources more than thresholds
CPU_USAGE=`top -b -n1 | grep $PROG | awk '{print $7}'`
MEM_USAGE=`top -b -n1 | grep $PROG | awk '{print $8}'`

# Give the response whether the current usage is below the thresholds
FLAG=0;
if [ `echo "$CPU_USAGE > $CPU_THRES" | bc` -eq 1 ] ; then
	echo "FATAL: CPU overload!"
	FLAG=1;
fi
if [ `echo "$MEM_USAGE > $MEM_THRES" | bc` -eq 1 ] ; then
	echo "FATAL: memory overload!"
	FLAG=1;
fi
if [ $FLAG -ne 1 ] ; then
	echo "The program is using acceptable amount of resources."
fi
exit 0
