#!/bin/bash
################################################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description: log for [INFO, WARNING, ERROR] 
#
################################################################################
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
