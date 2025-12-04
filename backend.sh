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

dnf module disable nodejs -y
VALIDATE $? "Disabling the default node js version"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling node js version 20"

dnf install nodejs -y
VALIDATE $? "Installing the nodejs"

useradd expense
VALIDATE $? "Adding the expense user "

mkdir /app
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading the code"

cd /app

unzip /tmp/backend.zip
VALIDATE $? "Unzipping the code into app directory"

npm install
VALIDATE $? "Installing the dependenciecs"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y
VALIDATE $? "Installing Mysql client"

mysql -h mysql.jobsearchindia.online -u root -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Loading the schema"

systemctl daemon-reload
VALIDATE $? "Daemon reload is "

systemctl enable backend
VALIDATE $? "enablling backend"

systemctl restart backend
VALIDATE $? "restart the backend"


