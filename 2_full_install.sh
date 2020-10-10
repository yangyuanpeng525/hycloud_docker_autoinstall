#!/bin/bash

#获取当前的路径
current_path=`pwd`
export PATH=$PATH

##初始化ansible控制机
#cd $current_path/Ansible_Install_HyCloud/scripts;bash ansibletool_install.sh

#解析表格
cd $current_path; python2 parse.py
if [ $? != 0 ];then
	exit 2
fi
#检测
cd $current_path/host_check;ansible-playbook -i all-inventory  play.yaml
#if [ $? != 0 ];then
#        exit 2
#fi


#下载
cd $current_path/Ansible_Install_HyCloud;bash wget_wait.sh
if [ $? != 0 ];then
        exit 2
fi

#拷贝应用包
cd $current_path/Ansible_Install_HyCloud/scripts ;bash hycloud_ready.sh




#执行
cd $current_path;python2  inventory_play.py
