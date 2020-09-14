#!/bin/bash

#获取当前的路径
current_path=`pwd`


cd $current_path/hy; python2 parse.py
cd $current_path/hy/Ansible_Install_HyCloud;bash wget.sh
