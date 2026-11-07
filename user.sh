#!/bin/bash

START_TIME=$(date +%s)

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


curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading user"

rm -rf /app/*
cd /app
unzip /tmp/user.zip
VALIDATE $? "unzipping user"

npm install &>>$LOG_FILE
VALIDATE $? "installing user"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable user &>>$LOG_FILE
systemctl start user &>>$LOG_FILE
VALIDATE $? "enable and starting user service"


END_TIME=$(date +%s)

TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

