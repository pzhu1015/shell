#!/bin/bash
################################################################################
#
# Author: pengzhihu1015@163.com
# Created : 2019/06/30
# Description: stop fire wall
# Tip:
#
################################################################################

systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl status firewalld.service
