#!/bin/bash

START_TIME=$(date +%s)

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

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

validate(){
if [ $1 -eq 0 ]
then
  echo -e "$2 is.. $G success $N" | tee -a $LOG_FILE
else
  echo -e "$2 is.. $R failed $N" | tee -a $LOG_FILE
  exit 1
fi
}


dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld &>>$LOG_FILE

validate $? "enabling and started mysql server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
validate $? "set user pwd  mysql server"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE