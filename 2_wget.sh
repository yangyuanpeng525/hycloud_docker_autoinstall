#!/bin/bash

#清除上次安装记录
rm  -rf /TRS/HyCloud_devops

rm  -rf tmp
rm  -f Ansible_Install_HyCloud/docs/inventory_list 
rm  -f Ansible_Install_HyCloud/docs/install_version.txt 
rm  -f Ansible_Install_HyCloud/info/dbinfo.yml 
rm  -f Ansible_Install_HyCloud/info/inventory 


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

#下载
cd $current_path/Ansible_Install_HyCloud;bash wget_wait.sh
if [ $? != 0 ];then
        exit 2
fi


##检测
#cd $current_path/host_check;ansible-playbook -i all-inventory  play.yaml
#if [ $? != 0 ];then
#        exit 2
#fi
#
#
##执行
#cd $current_path;python2  inventory_play.py
