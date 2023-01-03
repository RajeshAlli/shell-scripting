#!/bin/bash

action=$1
which java
if [ "$?" == "0" ]
then
  echo "java already installed"
else
  yum install -y openjdk-11-jdk
fi

case $action in
    start)
        wget https://get.jenkins.io/war-stable/2.375.1/jenkins.war
        sleep 60s
        if [ -f jenkins.war ]
        then
           java -jar jenkins.war &
        else
           echo "jenkins.war file not found"
        fi
        ;;
    stop)
        javaid=`ps -ef |grep jenkins.war|head -1 |cut -d " " -f5`
        kill -9 $javaid
        ;;
esac