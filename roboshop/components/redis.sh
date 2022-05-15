make #!/bin/bash

source components/common.sh
MSPACE=$(cat $0 | grep ^Print | awk -F '"' '{print $2}' | awk '{ print length }' | sort | tail -1)

Print "Install Redis Repos"
yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG
Stat $?

Print "Enable Redis Repos"
yum-config-manager --enable remi &>>$LOG
Stat $?

Print "Install Redis"
yum install redis -y &>>$LOG
Stat $?


Print "Update Redis Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>$LOG
Stat $?

DOWNLOAD() {
  Print "Download $redis"
  curl -s -L -o /tmp/${redis}.zip "https://github.com/roboshop-devops-project/${redis}/archive/main.zip" &>>$LOG
  Stat $?
  Print "Extract $redis Content"
  unzip -o -d $1 /tmp/${redis}.zip &>>$LOG
  Stat $?
  if [ "$1" == "/home/roboshop" ]; then
    Print "Remove Old Content"
    rm -rf /home/roboshop/${redis}
    Stat $?
    Print "Copy Content"
    mv /home/roboshop/${redis}-main /home/roboshop/${redis}
    Stat $?
  fi
}

Print "Load Schema"
cd /tmp/redis-main
for db in cart users ; do
  redis < $db.js &>>$LOG
done
Stat $?

Print "Start Redis Database"
systemctl enable redis &>>$LOG && systemctl restart redis &>>$LOG
Stat $?
