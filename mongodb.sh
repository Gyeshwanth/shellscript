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
  echo -e "$2 is.. $G success $N" | tee -a LOG_FILE
else
  echo -e "$2 is.. $R failed $N" | tee -a LOG_FILE
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y &>>LOGS_FILE
validate $? "installing mongodb"

systemctl enable mongod &>>LOG_FILE
validate $? "enabling mongodb"
systemctl start mongod &>>LOG_FILE
validate $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Update listen address"

systemctl restart mongod
validate $? "restarting mongodb"

