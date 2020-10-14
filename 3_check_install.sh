#!/bin/bash

#获取当前的路径
current_path=`pwd`
export PATH=$PATH

##初始化ansible控制机
#cd $current_path/Ansible_Install_HyCloud/scripts;bash ansibletool_install.sh

#解析表格
#cd $current_path; python2 parse.py
#if [ $? != 0 ];then
#	exit 2
#fi
#
##下载
#cd $current_path/Ansible_Install_HyCloud;bash wget_wait.sh
#if [ $? != 0 ];then
#        exit 2
#fi
#

#检测
cd $current_path/host_check;ansible-playbook -i all-inventory  play.yaml
if [ $? != 0 ];then
	echo "服务器检测未通过，退出安装！！！"
        exit 2
fi
echo  -e "服务器检测全部通过，开始安装海云。\n"

#拷贝应用包
echo "--------------- 开始拷贝介质 ---------------"
cd $current_path/Ansible_Install_HyCloud/scripts ;bash hycloud_ready.sh



#执行
echo -e "\n-------------- 开始安装海云 --------------"
cd $current_path;python2  inventory_play.py
if [ $? != 0 ];then
	echo "安装未完成，联系管理员！！！"
        exit 2
fi

echo "安装成功！请前往浏览器验证。"

