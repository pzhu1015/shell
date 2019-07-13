#!/bin/bash
################################################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/07/01
# Description: one click to install hadoop
# Tip: hadoop-2.8.3
# 1. set_ssh_nopwd.sh set hadoop cluster all machine ssh login for no password
# 2. install_java.sh to install jdk and set java env foreach machine
# 3. untar the hadoop source package rename directory to hadoop/
# 4. cd ~/hadoop/etc/hadoop/
# 5. vim core-site.xml, hdfs-site.xml, mapred-site.xml, yarn-site.xml, slaves
#
################################################################################
WORKDIR=$(cd $(dirname $0); pwd)
USERNAME=`whoami`

#include log function
LOG=${WORKDIR}/log.sh
if [ ! -f ${LOG} ]
then
    printf "\r`date "+%F %T"` [ \033[0;31mERROR\033[0m ] [${LOG} does not exist]\n"
	exit 127
else
	source ${LOG}
	if [ $? -ne "0" ]
	then
		printf "\r`date "+%F %T"` [ \033[0;31mERROR\033[0m ] [${LOG} execute failed]\n"
		exit
	fi
fi

#include configuration for ip address and password
CONFIG=${WORKDIR}/config

if [ ! -f ${CONFIG} ]
then
	log error "[${CONFIG}] does not exist"
	exit 127
else
	source ${CONFIG}
	if [ $? -ne "0" ]
	then
		log error "[${CONFIG}] execute failed"
		exit
	fi
fi

#set no password
NOPWD=${WORKDIR}/set_ssh_nopwd.sh 
if [ ! -f ${NOPWD} ]
then
	log error "[${NOPWD}] does not exists"
	exit 127
else
	source ${NOPWD}
	if [ $? -ne 0 ]
	then
		log error "[${NOPWD}] execute failed"
		exit
	fi
fi

log info "Set ssh no password successfully."

set_hadoop()
{
	local IP=$1
    scp ${WORKDIR}/set_hadoop.sh ${WORKDIR}/config ${WORKDIR}/${HADOOP_SOURCE} ${USERNAME}@${IP}:$HOME
	ssh ${USERNAME}@${IP} source $HOME/set_hadoop.sh "${IP}"
}

for IP in ${!IPList[@]}; do
	log info "Start to install hadooop for [${IP}]..."
	set_hadoop ${IP} &
done
wait

if [ $? -ne 0 ]
then
	log error "Install hadoop failed."
else
	log info "Install hadoop successfully."
fi
