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
#source /etc/profile
#set -e
WORKDIR=$(cd $(dirname $0); pwd)
CONFIG=${WORKDIR}/config

if [ ! -f ${CONFIG} ]
then
	exit 127
else
	source ${CONFIG}
	if [ $? -ne 0 ]
	then
		exit
	fi
fi

mkdir -p ${HADOOP_BASE}
echo "[$1] [tar -zxvf ${WORKDIR}/${HADOOP_SOURCE} -C ${HADOOP_BASE}]..."
HADOOP_DIR_NAME=`tar -zxvf ${WORKDIR}/${HADOOP_SOURCE} -C ${HADOOP_BASE} | tail -n1 | awk -F "/" '{print $1}'`
if [ $? -ne 0 ]
then
	exit
fi

HADOOP_HOME=${HADOOP_BASE}/${HADOOP_DIR_NAME}

#write hadoop environment variables to .bashrc  if not exist
grep -q "export HADOOP_HOME" $BASHRC
if [ $? -ne 0 ]
then
    echo "[$1] Hadoop environment variables not exist,starting define it"
	echo "export HADOOP_HOME=$HADOOP_HOME" >> $BASHRC
	echo 'export CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath):$CLASSPATH' >> $BASHRC
	echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> $BASHRC
	echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> $BASHRC
	echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> $BASHRC
	echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib:$HADOOP_COMMON_LIB_NATIVE_DIR"' >> $BASHRC
fi

#set core-site.xml
coresite=""
coresite=$coresite"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
coresite=$coresite"<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n"
coresite=$coresite"<configuration>\n"
coresite=$coresite"\t<property>\n"
coresite=$coresite"\t\t<name>hadoop.tmp.dir</name>\n"
coresite=$coresite"\t\t<value>$HADOOP_HOME/tmp</value>\n"
coresite=$coresite"\t</property>\n"
coresite=$coresite"\t<property>\n"
coresite=$coresite"\t\t<name>fs.defaultFS</name>\n"
coresite=$coresite"\t\t<value>hdfs://$1:9000</value>\n"
coresite=$coresite"\t</property>\n"
coresite=$coresite"</configuration>" 
echo -e $coresite > $HADOOP_HOME/etc/hadoop/core-site.xml

#set hdfs-site.xml
hdfssite=""
hdfssite=$hdfssite"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
hdfssite=$hdfssite"<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n"
hdfssite=$hdfssite"<configuration>\n"
hdfssite=$hdfssite"\t<property>\n"
hdfssite=$hdfssite"\t\t<name>dfs.replication</name>\n"
hdfssite=$hdfssite"\t\t<value>1</value>\n"
hdfssite=$hdfssite"\t</property>\n"
hdfssite=$hdfssite"\t<property>\n"
hdfssite=$hdfssite"\t\t<name>dfs.namenode.name.dir</name>\n"
hdfssite=$hdfssite"\t\t<value>$HADOOP_HOME/tmp/dfs/name</value>\n"
hdfssite=$hdfssite"\t</property>\n"
hdfssite=$hdfssite"\t<property>\n"
hdfssite=$hdfssite"\t\t<name>dfs.datanode.data.dir</name>\n"
hdfssite=$hdfssite"\t\t<value>$HADOOP_HOME/tmp/dfs/data</value>\n"
hdfssite=$hdfssite"\t</property>\n"
hdfssite=$hdfssite"\t<property>\n"
hdfssite=$hdfssite"\t\t<name>dfs.permissions</name>\n"
hdfssite=$hdfssite"\t\t<value>false</value>\n"
hdfssite=$hdfssite"\t</property>\n"
hdfssite=$hdfssite"</configuration>" 
echo -e $hdfssite > $HADOOP_HOME/etc/hadoop/hdfs-site.xml

source /etc/profile
set -e

#change hadoop-env.sh JAVA_HOME
sed -i 's/export JAVA_HOME=.*/\#&/' $HADOOP_HOME/etc/hadoop/hadoop-env.sh
sed -i "/#export JAVA_HOME=.*/a export JAVA_HOME=$JAVA_HOME" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

echo "[$1] Config Hadoop Environment Variables Successfully"
