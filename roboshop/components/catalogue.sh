#!/bin/bash

source components/common.sh

Print "install NodeJS"
yum install nodejs make gcc-c++ -y &>>$LOG
Stat $?

Print "Add RoboShop User"
id roboshop &>>$LOG
if [ $? -eq 0 ]; then
  echo User RoboShop already exists &>>$LOG
else
  useradd roboshop  &>>$LOG
fi
Stat $?

Print "Download Catalogue"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>$LOG
Stat $?

Print "Remove Old Content"
rm -rf /home/roboshop/catalogue &>>$LOG
Stat $?

Print "Extract Catalogue"
unzip -o -d /home/roboshop /tmp/catalogue.zip &>>$LOG
Stat $?

Print "copy content"
mv /home/roboshop/catalogue-main /home/roboshop/catalogue &>>$LOG
Stat $?

Print "Install NodeJS Dependencies"
cd /home/roboshop/catalogue
npm run ng --version --unsafe-perm &>>$LOG
Stat $?

SYSTEMD() {
  Print "Fix App Permissions"
  chown -R roboshop:roboshop /home/roboshop
  Stat $?

  Print "Update DNS records in SystemD config"
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service   &>>$LOG
  Stat $?

  Print "Copy SystemD file"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  Stat $?

  Print "Start ${COMPONENT_NAME} Service"
  systemctl daemon-reload &>>$LOG && systemctl restart ${COMPONENT} &>>$LOG && systemctl enable ${COMPONENT} &>>$LOG
  Stat $?
}

# mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
# systemctl daemon-reload
# systemctl start catalogue
# systemctl enable cataloguels
