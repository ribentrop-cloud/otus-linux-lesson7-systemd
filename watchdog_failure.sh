#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
        logger "$DATE : I found, Master!"
        exit 143
else
	logger "$DATE : Not found . Still working , Master!"
        exit 1
fi
