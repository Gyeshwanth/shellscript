
USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

LOGS_FOLDER="/var/logs/robotshop-logs"
SCRIPT_NAME=$(echo $0 | awk -F "." {'print $f1'})
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mikdir -p $LOGS_FOLDER
echo "Script started executing at:" $(date) | tee -a $LOG_FILE

