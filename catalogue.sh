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


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "enabling default nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"


id roboshop
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop system user"
else
 echo -e "System user roboshop already created ...  SKIPPING $N"
fi


mkdir -p /app
VALIDATE $? "Creating app directory"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue"

rm -rf /app/*
cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "installing catalogue"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "enable and starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Client"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0]
then
  mongosh --host mongodb.yefy.shop </app/db/master-data.js
else
   echo -e "Data is already loaded ...  SKIPPING $N"
fi