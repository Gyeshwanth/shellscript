#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
SCRIPT_DIR=$PWD

LOG_FOLDER="/var/log/robotshop"
SCRIPT_NAME=$(echo $0 |awk -F "." {'print $1'})
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER
echo "Script started executing: " $(date) | tee -a $LOG_FILE

if [ $USER_ID -eq 0 ]
then
  echo -e "$G you running as root user" | tee -a $LOG_FILE
else
  echo -e "$R Please run this script with root user" | tee -a $LOG_FILE
  exit 1
fi


VALIDATE(){
  if [ $1 -eq 0 ]
  then
    echo -e "$2 is .. $G Success" | tee -a $LOG_FILE
  else
    echo -e "$2 is .. $R failed" | tee -a $LOG_FILE
   exit 1
  fi
}

dnf module disable nginx -y  &>>$LOG_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y  &>>$LOG_FILE
VALIDATE $? "enabling default nginx"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "installing nginx"



systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx  &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "removing default html file content in nginx"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"


cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"


systemctl restart nginx
VALIDATE $? "restarting nginx"
