#!/bin/bash
#
# chkconfig: 2345 95 20
# description: Tomcat 8 start/stop/status init.d script
# processname: tomcat
#
# Tomcat 8 start/stop/status init.d script
#/ttt

# Updates:
# @author: Tongliang Liu <cooniur@gmail.com>
# Added chkconfig header to make it work with chkconfig
#
# Initially forked from: https://gist.github.com/valotas/1000094
# @author: Miglen Evlogiev <bash@miglen.com>
#
# Original Release updates:
# Updated method for gathering pid of the current proccess
# Added usage of CATALINA_BASE
# Added coloring and additional status
# Added check for existence of the tomcat user
# Added termination proccess
# 

#Location of JAVA_HOME (the directory contains bin folder)
export JAVA_HOME=/opt/java8

#Add Java binary files to PATH
export PATH=$JAVA_HOME/bin:$PATH

#CATALINA_HOME is the location of the bin files of Tomcat  
#export CATALINA_HOME=/var/local/tomcat

#CATALINA_BASE is the location of the configuration files of this instance of Tomcat
#export CATALINA_BASE=/var/local/tomcat

#TOMCAT_USER is the default user of tomcat
export TOMCAT_USER=root

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {\e[00;32mstart\e[00m|\e[00;31mstop\e[00m|\e[00;31mkill\e[00m|\e[00;32mstatus\e[00m|\e[00;31mrestart\e[00m}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=20

tomcat_pid() {
  echo `ps -fe | grep $CATALINA_BASE | grep -v grep | tr -s " "|cut -d" " -f2`
}

start() {
for CATALINA_HOME in /tomcat/Dev/Tomcat1 /tomcat/Dev/Tomcat2
do
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_HOME
echo "CATALINA_HOME="$CATALINA_HOME
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;31mTomcat is already running $CATALINA_HOME (pid: $pid)\e[00m"
  else
    # Start tomcat
    echo -e "\e[00;32mStarting tomcat from $CATALINA_HOME \e[00m"
    ulimit -n 100000
    umask 007
    if [ `user_exists $TOMCAT_USER` = "1" ]
    then
     # /bin/su $TOMCAT_USER -c 
  sh $CATALINA_HOME/bin/startup.sh
    else
      sh $CATALINA_HOME/bin/startup.sh
    fi
    status
  fi
  #return 0
done
}

status(){
for CATALINA_HOME in /tomcat/Dev/Tomcat1 /tomcat/Dev/Tomcat2
do
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_HOME
echo "CATALINA_HOME="$CATALINA_HOME
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;32mTomcat is running from $CATALINA_HOME with pid: $pid\e[00m"
  else
    echo -e "\e[00;31mTomcat is not running from $CATALINA_HOME \e[00m"
  fi
done
}

terminate() {
for CATALINA_HOME in /tomcat/Dev/Tomcat1 /tomcat/Dev/Tomcat2
do
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_HOME
echo "CATALINA_HOME="$CATALINA_HOME
  echo -e "\e[00;31mTerminating Tomcat $CATALINA_HOME \e[00m"
  kill -9 $(tomcat_pid)
done
}


stop() {
for CATALINA_HOME in /tomcat/Dev/Tomcat1 /tomcat/Dev/Tomcat2
do
CATALINA_HOME=$CATALINA_HOME
CATALINA_BASE=$CATALINA_HOME
echo "CATALINA_HOME="$CATALINA_HOME
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;31mStoping Tomcat $CATALINA_HOME \e[00m"
    sh $CATALINA_HOME/bin/shutdown.sh

    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\n\e[00;31mwaiting for processes to exit $CATALINA_HOME \e[00m";
      sleep 1
      let count=$count+1;
    done
    if [ $count -gt $kwait ]; then
      echo -n -e "\n\e[00;31mkilling processes didn't stop from $CATALINA_HOME after $SHUTDOWN_WAIT seconds\e[00m"
      terminate
    fi
  else
    echo -e "\e[00;31mTomcat is not running from $CATALINA_HOME \e[00m"
  fi

 # return 0
done
}

user_exists(){
  if id -u $1 >/dev/null 2>&1; then
    echo "1"
  else
    echo "0"
  fi
}

case $1 in
  start)
   start
  ;;
  stop)
    stop
  ;;
  restart)
    stop
    start
  ;;
  status)
    status
  ;;
  kill)
    terminate
  ;;
  *)
    echo -e $TOMCAT_USAGE
  ;;
esac

exit 0
                    
