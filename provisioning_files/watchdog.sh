#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
        logger "$DATE : This is NORMAL WATCHDOG servce! I found pattern, Master!"
else
        exit 0
fi
