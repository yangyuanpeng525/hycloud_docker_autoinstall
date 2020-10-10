#!/bin/bash

#获取当前的路径
current_path=`pwd`
export PATH=$PATH

#初始化ansible控制机
cd $current_path/Ansible_Install_HyCloud/scripts;bash ansibletool_install.sh

