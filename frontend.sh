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

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing nginx" 

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enablling nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "Strating nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing the default html data"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading the code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Moving to html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping the code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Restarting nginx"