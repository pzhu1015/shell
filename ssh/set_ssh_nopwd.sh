#!/bin/bash
################################################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description: set ssh login for no password
# Tip:
# modify [IPList]
#
################################################################################
declare -A IPList
USER_NAME=`whoami`
IPList=(
[192.168.1.100]="12345"
[192.168.1.101]="12345"
[192.168.1.102]="12345"
[192.168.1.103]="12345"
)

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
            log err "Installation failed, please install the expect command manually."
            exit 1
        else
            log info "Installation successed."
        fi
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
           log err "Generated ssh key failed."
       fi
   else
       echo "y" | ${ssh_keygen} -t ${ssh_key_type} -P "${ssh_pwd}" -f ${ssh_pri_key} &> /dev/null
       if [ $? -eq 0 ]; then
           log info "Generated ssh key successfully."
       else
           log err "Generated ssh key failed."
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
           log info "Copy the ssh pub key to $IP successfully."
       else
           log err "Copy the ssh pub key to $IP failed."
       fi
}


# main
check_expect
generate_ssh_key
for ip in ${!IPList[@]}; do
    copy_pub_key $ip
done
