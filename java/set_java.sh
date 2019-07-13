##############################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description:  auto install local machine java and set env
# Tip:
# modify [JAVA_SOURCE, JAVA_BASE]
#
##############################################################
#!/bin/bash
WORKDIR=$(cd $(dirname $0); pwd)
CONFIG=${WORKDIR}/config

if [ ! -f ${CONFIG} ]
then
	exit 127
else
	source ${CONFIG}
	if [ $? -ne "0" ]
	then
		exit
	fi
fi

mkdir -p ${JAVA_BASE}
echo "[$1] [tar -zxvf ${WORKDIR}/${JAVA_SOURCE} -C ${JAVA_BASE}]"
JAVA_DIR_NAME=`tar -zxvf ${WORKDIR}/${JAVA_SOURCE} -C ${JAVA_BASE} | tail -n1 | awk -F "/" '{print $1}'`
if [ $? -ne 0 ]
then
	exit
fi

JAVA_HOME=${JAVA_BASE}/${JAVA_DIR_NAME}
 
JAVA_BIN=$JAVA_HOME/bin
 
PATH=$PATH:$JAVA_BIN
 
CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
 
#write java environment variables to .bashrc  if not exist
grep -q "export JAVA_HOME" $BASHRC
if [ $? -ne 0 ]; then
    echo "Java environment variables not exist,starting define it"
	echo "export JAVA_HOME="$JAVA_HOME >> $BASHRC
	echo "export JAVA_BIN="$JAVA_BIN >> $BASHRC
	echo "export PATH=\$PATH:\$JAVA_BIN" >> $BASHRC
	echo "export CLASSPATH="\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar >> $BASHRC
fi
echo "[$1] Config Java Environment Variables Success"
