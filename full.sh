#!/bin/bash

#获取当前的路径
current_path=`pwd`
export PATH=$PATH

#解析表格
cd $current_path; python2 parse.py
if [ $? != 0 ];then
	exit 2
fi
#检测
cd $current_path/host_check;ansible-playbook -i all-inventory  play.yaml


#下载
cd $current_path/Ansible_Install_HyCloud;bash wget.sh.wait
if [ $? != 0 ];then
        exit 2
fi
#执行
cd $current_path;python2  inventory_play.py
