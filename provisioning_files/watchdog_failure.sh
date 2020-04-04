#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
        logger "$DATE : This is FAILURE WATCHDOG servce! I found pattern, Master!"
        exit 143
else
	logger "$DATE : This is FAILURE WATCHDOG servce! Pattern not found . Still working , Master!"
        exit 1
fi

