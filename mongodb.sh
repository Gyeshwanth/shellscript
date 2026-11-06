#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGS_FOLDER="/var/log/robotshop-logs"
SCRIPT_NAME=$(echo $0 | awk -F "." {'print $1'})
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at:" $(date) | tee -a $LOG_FILE


if [ $USER_ID -eq 0 ]
then
   echo "your running as root user" | tee -a $LOG_FILE

else
   echo -e "$R ERROR:: Please run this script as root user $N" | tee -a $LOG_FILE
   exit 1
fi

validate(){
if [ $1 -eq 0 ]
then
  echo -e "$2 is $G success $N" | tee -a LOGS_FILE
else
  echo -e "$ is $R failed $N" | tee -a LOGS_FILE
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"


