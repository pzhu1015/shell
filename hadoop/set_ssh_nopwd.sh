#!/bin/bash
################################################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description: set ssh login for no password
#
################################################################################
WORKDIR=$(cd $(dirname $0); pwd)
USER_NAME=`whoami`
# for ssh
ssh_keygen="/usr/bin/ssh-keygen"
ssh_key_type="rsa"
ssh_pwd=''
ssh_key_base_dir=~/.ssh
ssh_pri_key=$ssh_key_base_dir/id_rsa
ssh_pub_key=$ssh_key_base_dir/id_rsa.pub
ssh_known_hosts=$ssh_key_base_dir/known_hosts
ssh_copy_id="/usr/bin/ssh-copy-id"


command_exists() {
	command -v "$@" > /dev/null 2>&1
}

install_expect() {
    yum -y install expect &> /dev/null
}

check_expect() {
    if ! command_exists expect; then
        log warn "No expect command and try to install, please wait..."
        install_expect
        if ! command_exists expect; then
            log error "Installation failed, please install the expect command manually."
            exit 1
        else
            log info "Installation successed."
        fi
	else
       log info "[expect] for sepcify password exist"
	fi
}

get_cipher() {
    local IP=$1

    for key in ${!IPList[@]}; do
        if [[ X"$IP" == X"$key" ]]; then
            PASSWORD="${IPList[$key]}"
        fi
    done
}

is_exist() {
    local IP=$1

    if `grep -q "$IP" ${ssh_known_hosts}`; then
        return 0
    fi

    return 1
}

del_exist_host() {
    local IP=$1

    sed -i "/$IP/d" ${ssh_known_hosts}
}

generate_ssh_key() {
   if [ ! -f ${ssh_pri_key} ]; then
       ${ssh_keygen} -t ${ssh_key_type} -P "${ssh_pwd}" -f ${ssh_pri_key} &> /dev/null
       if [ $? -eq 0 ]; then
           log info "Generated ssh key successfully."
       else
           log error "Generated ssh key failed."
		   exit 1
       fi
   else
       echo "y" | ${ssh_keygen} -t ${ssh_key_type} -P "${ssh_pwd}" -f ${ssh_pri_key} &> /dev/null
       if [ $? -eq 0 ]; then
           log info "Generated ssh key successfully."
       else
           log error "Generated ssh key failed."
		   exit 1
       fi
   fi
}

copy_pub_key() {
   local IP=$1

   if [ -f ${ssh_known_hosts} ]; then
       is_exist $IP
       if [ $? -eq 0 ]; then
           del_exist_host $IP
       fi
   fi
   
   get_cipher $IP
   
   expect -c <<- EOF &> /dev/null "
       spawn $ssh_copy_id -i "$ssh_pub_key" $USER_NAME@$IP
       expect {
            \"(yes/no)?\" {
                send \"yes\r\"
                expect {
                    "*assword" {
                        send \"$PASSWORD\r\"
                    }
                }
            }
            "*assword*" {
                send \"$PASSWORD\r\"
            }
            expect eof    
        }
        catch wait retVal
        exit [lindex \$retVal 3]"
EOF
       if [ $? -eq 0 ]; then
           log info "Copy the ssh pub key to [$IP] successfully."
       else
           log error "Copy the ssh pub key to [$IP] failed."
		   exit 1
       fi
}


# main
log info "Start to check install expect command..."
check_expect
log info "Start to generate ssh key..."
generate_ssh_key
for ip in ${!IPList[@]}; do
	log info "Start to Copy ssh pub key to [$ip]..."
    copy_pub_key $ip
done
