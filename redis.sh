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

echo "Script started executing at " $(date) | tee -a $LOG_FILE

echo ":who is running :$USER_ID" | tee -a $LOG_FILE

if [ USER_ID -eq 0 ]
then
echo -e "$G you running this script as root user" | tee -a $LOG_FILE
else
echo -e "$R Please run this script as root user" | tee -a $LOG_FILE
exit 1
fi

validate(){

if [ $1 -eq 0 ]
then
  echo -e "$2 is ... $G Success" | tee -a $LOG_FILE
else
  echo -e "$2 is ... $R Failed " | tee -a $LOG_FILE
  exit 1
fi
}


dnf module disable redis -y &>>$LOG_FILE
validate $? "disabling redis"
dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "enabling redis"

dnf install redis -y &>>$LOG_FILE
validate $? "installing redis"

# -e means multiple value updated with single cmd sed
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Update listen address"


systemctl enable redis &>>$LOG_FILE
validate $? "enabling redis"

systemctl start redis &>>$LOG_FILE
validate $? "starting redis"

END_TIME=$(date +%s)

TOTAL_TIME = $(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE



