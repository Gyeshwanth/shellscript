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

echo "please enter mysql root password"
read -s MYSQL_ROOT_PASSWORD

VALIDATE(){
  if [ $1 -eq 0 ]
  then
    echo -e "$2 is .. $G Success" | tee -a $LOG_FILE
  else
    echo -e "$2 is .. $R failed" | tee -a $LOG_FILE
   exit 1
  fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "installing maven"

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


curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip >>$LOG_FILE
VALIDATE $? "Downloading shipping"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip
VALIDATE $? "unzipping shipping"


mvn clean package >>$LOG_FILE
VALIDATE $? "maven clean package for shipping"

mv target/shipping-1.0.jar shipping.jar >>$LOG_FILE
VALIDATE $? "moving  shipping.jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying shipping service"

systemctl daemon-reload  &>>$LOG_FILE
systemctl enable shipping &>>$LOG_FILE
systemctl start shipping &>>$LOG_FILE

VALIDATE $? "enable and starting shipping service"


dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing mysql server"


mysql -h mysql.yefy.shop -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0 ]
then
  mysql -h mysql.yefy.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
  mysql -h mysql.yefy.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
  mysql -h mysql.yefy.shop -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
  VALIDATE $? "Loading data into MySQL"
else
   echo -e "Data is already loaded into MySQL ...  SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"
