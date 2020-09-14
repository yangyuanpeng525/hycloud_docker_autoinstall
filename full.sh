#!/bin/bash

#获取当前的路径
current_path=`pwd`


cd $current_path; python2 parse.py
cd $current_path/Ansible_Install_HyCloud;bash wget.sh
