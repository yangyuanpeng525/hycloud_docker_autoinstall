#!/bin/bash

#获取当前的路径
current_path=`pwd`


cd $current_path; python2 parse.py
if [ $? != 0 ];then
	exit 2
fi

cd $current_path/Ansible_Install_HyCloud;bash wget.sh.wait
