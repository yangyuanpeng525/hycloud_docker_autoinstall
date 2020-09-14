#!/bin/bash

SOFT_FILE="/tmp/ansible_tmp"
SOFT_NAME="docker-19.03.8.tgz"
Ansible_tar="ansible-2.5.1.tar"
mysql_python="MySQL-python-1.2.5-1.el7.x86_64.rpm"
PATH_docker="/usr/bin"
##PATH_docker="/haha"


#检测MySQL-Python
rpm -qa  | grep MySQL-python &> /dev/null
if [ $? != 0 ];then
	rpm -ivh $SOFT_FILE/$mysql_python
fi

#检测ansible命令
#定义检测结果
ansible --version &> /dev/null

if [ $? != 0 ];then

	echo -e  "\033[31m！！！ansible控制主机开始安装ansile工具！！！\033[0m"
else

	echo -e  "\033[32m！！！ansible控制主机已经安装ansible！！！\033[0m"

	exit 1
fi

#安装docker
#检测docker是否已经安装
docker --version  &> /dev/null

if [ $? != 0 ];then

        echo -e  "\033[31m！！！ansible控制主机未安装docker！！！\033[0m"
	echo -e  "\033[32m！！！ansible控制主机开始安装docker ！！！\033[0m"
	cd $SOFT_FILE

	tar -xf $SOFT_NAME
	mv $SOFT_FILE/docker/* $PATH_docker
	rm -rf $SOFT_FILE/docker
	echo -e  "\033[32m！！！ansible控制主机docker安装完成 ！！！\033[0m"

fi

#安装ansible
docker load -i $SOFT_FILE/$Ansible_tar  &> /dev/null
docker rm -f ansible &> /dev/null
docker run --rm -it -d --name ansible -v /TRS:/TRS ansible:2.5.1-ubuntu bash  &> /dev/null
echo -e "\033[32m！！！ansible容器名：ansible！！！\033[0m"
echo -e  "\033[32m！！！ansible工具已装好，请到使用 'docker exec -it ansible bash' 命令到容器内开始安装海云 ！！！\033[0m"

