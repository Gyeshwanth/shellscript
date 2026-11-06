#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGS_FOLDER="/var/logs/robotshop-logs"
SCRIPT_NAME=$(echo $0 | awk -F "." {'print $f1'})
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at:" $(date) | tee -a $LOG_FILE


if [ $? ne 0 ]
then
  echo -e "$R ERROR:: Please run this script as root user $N" | tee -a $LOG_FILE
  exit 1
else
  echo "your running as root user" | tee -a $LOG_FILE
fi




