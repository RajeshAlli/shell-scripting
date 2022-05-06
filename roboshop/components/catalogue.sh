#!/bin/bash

source components/common.sh

MSPACE=$(cat $0 components/common.sh | grep ^Print | awk -F '"' '{print $2}' | awk '{ print length }' | sort | tail -1)

 Print "Install NodeJS dependencies"
  cd /home/roboshop/${COMPONENT}
  npm install --unsafe-perm &>>$LOG
  Stat $?


COMPONENT_NAME=Catalogue
COMPONENT=catalogue
NODEJS
CHECK_MONGO_FROM_APP