##############################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description:  auto install java and set env
# Tip:
# modify [JAVA_SOURCE, JAVA_BASE]
#
##############################################################
#!/bin/bash
WORKDIR=$(cd $(dirname $0); pwd)
#bashrc
BASHRC=/etc/profile
#set java source tar file
JAVA_SOURCE=jdk-8u11-linux-x64.tar.gz

#set java install directory
JAVA_BASE=/usr/lib/jvm

info() {
    printf "\r`date "+%F %T"` [ \033[00;32mINFO\033[0m ]%s\n" "$1"
}

warn() {
    printf "\r`date "+%F %T"` [\033[0;33mWARN\033[0m]%s\n" "$1"
}

error() {
    printf "\r`date "+%F %T"` [ \033[0;31mERROR\033[0m ]%s\n" "$1"
}

usage() {
    echo "Usage: ${0##*/} {info|warn|error} MSG"
}

log() {
    if [ $# -lt 2 ]; then
        log error "Not enough arguments [$#] to log."
    fi

    __LOG_PRIO="$1"
    shift
    __LOG_MSG="$*"

    case "${__LOG_PRIO}" in
        error) __LOG_PRIO="ERROR";;
        warn) __LOG_PRIO="WARNING";;
        info) __LOG_PRIO="INFO";;
    esac

    if [ "${__LOG_PRIO}" = "INFO" ]; then
        info " $__LOG_MSG"
    elif [ "${__LOG_PRIO}" = "WARN" ]; then
        warn " $__LOG_MSG"
    elif [ "${__LOG_PRIO}" = "ERROR" ]; then
        error " $__LOG_MSG"
    else
       usage
    fi
}

if [ ! -f ${WORKDIR}/$JAVA_SOURCE ]
then
	log error "Source File [${WORKDIR}/$JAVA_SOURCE] does not exist"
	exit
fi


mkdir -p $JAVA_BASE
JAVA_DIR_NAME=`tar -zxvf ${WORKDIR}/$JAVA_SOURCE -C $JAVA_BASE | tail -n1 | awk -F "/" '{print $1}'`

JAVA_HOME=$JAVA_BASE/$JAVA_DIR_NAME
log info [JAVA_HOME=$JAVA_HOME]
 
JAVA_BIN=$JAVA_HOME/bin
log info [JAVA_BIN=$JAVA_BIN]
 
PATH=$PATH:$JAVA_BIN
log info [PATH=$PATH]
 
CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
log info [CLASSPATH=$CLASSPATH]
 
#write java environment variables to .bashrc  if not exist
grep -q "export JAVA_HOME" $BASHRC
if [ $? -ne 0 ]; then
    log info "Java environment variables not exist,starting define it"
	echo "export JAVA_HOME="$JAVA_HOME >> $BASHRC
	echo "export JAVA_BIN="$JAVA_BIN >> $BASHRC
	echo "export PATH=\$PATH:\$JAVA_BIN" >> $BASHRC
	echo "export CLASSPATH="\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar >> $BASHRC
fi
log info "Config Java Environment Variables Success"
source $BASHRC
