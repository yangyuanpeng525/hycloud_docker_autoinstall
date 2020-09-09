#!/bin/bash

#获取当前的路径
current_path=`pwd`

#定义变量文件
var_file="var"

#url
#url="http://d.devdemo.trs.net.cn/hy/devops-hy"

url=`cat $current_path/$var_file | grep -v "#" | grep url | awk '{print $2}'`

#将inventory中的组提取出来
inventory_list="inventory_tmp"

#最新版本号
latest_version="latest_version.txt"

#本次安装版本号
install_version="version_tmp.txt"

#appname为安装的应用   
#appversion为对应应用的版本号

#定义下载包的前后缀
prefix="install_"
suffix=".tar.gz"

cat $current_path/inventory  | grep -v "#" | grep "\[" | grep  -v ":"  |  awk -F  "["  '{print $2}' | awk -F "]"   '{print $1}' > $current_path/inventory_tmp
install_num=`cat inventory_tmp | wc -l`

#更新 $install_version文件
> $current_path/$install_version

for i in `seq $install_num`
do 
	appname=`cat $current_path/$inventory_list |  awk  "NR==$i {print}"`
	cat $current_path/$latest_version | grep $appname: >> $current_path/$install_version
if [ $? != 0 ];then 
	echo -e "未找到\t$appname    的最新版本号，跳过。"
	continue
fi
done
#删除tmp文件
rm -rf $current_path/$inventory_list

#将版本号和应用拆分，拼接为url并下载安装包
for app_version  in `cat $current_path/$install_version`
do
	appname=`echo $app_version | cut -d : -f 1`
	appversion=`echo $app_version | cut -d : -f 2`
	echo "$url/$appname/$prefix$appname-$appversion$suffix"
done
#rm -rf $current_path/$install_version
