#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$FILE_NAME-$TIME_STAMP.log"

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .....$R Failure $N"
        exit 1
    else
        echo -e " $2 .....$G Success $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo -e " $R ERROR: $N User Must have Root access to run this script "
    exit 1
fi

echo "Script started executing at: $TIME_STAMP" 

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Mysql server is"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Mysql server is"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting Mysql server is"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up Root Password is"

