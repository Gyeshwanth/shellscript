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

dnf install python3 gcc python3-devel -y &>>LOG_FILE
VALIDATE $? "Installing python3"

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

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip >>$LOG_FILE
VALIDATE $? "Downloading payment"

rm -rf /app/*
cd /app
unzip /tmp/payment.zip
VALIDATE $? "unzipping payment"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "copying payment service"

systemctl daemon-reload
VALIDATE $? "reload payment service"

systemctl enable payment
systemctl start payment
VALIDATE $? "enabling and starting payment service"

