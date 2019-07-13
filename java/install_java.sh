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
USERNAME=`whoami`

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

#2. set no password
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
	log info "Set ssh no password successfully."
fi

set_java()
{
	local IP=$1
    scp ${WORKDIR}/set_java.sh ${WORKDIR}/config ${WORKDIR}/${JAVA_SOURCE} ${USERNAME}@${IP}:$HOME
	ssh ${USERNAME}@${IP} source $HOME/set_java.sh "${IP}"
}

for IP in ${!JavaIPList[@]}; do
	log info "Start to install java for [${IP}]..."
	set_java ${IP} &
done
wait

if [ $? -ne 0 ]
then
	log error "Install java failed."
else
	log info "Install java successfully."
fi
