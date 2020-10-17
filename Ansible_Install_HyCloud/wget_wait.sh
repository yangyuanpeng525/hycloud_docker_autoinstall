#!/bin/bash
#获取当前的路径
current_path=`pwd`

file="Ansible_Install_HyCloud"
#定义变量文件
var_file="var"

#定义存放ansible包的临时目录
file_tmp="tmp/tmp-hy-ansible"
images_tmp="tmp/tmp-images"
tmp="tmp"

#脚本目录
scrips="scripts"

#inventory db目录
info="info"

#ansible环境安装脚本
ansibletool_install_sh="ansibletool_install.sh"
ansibletool_install_sh_result="ansibletool_install_result.txt"

#md5校验脚本
md5_check_sh_tmp="md5_check.sh.temp"
md5_check_sh="md5_check.sh "

#整合roles目录脚本
integration_sh_tmp="integration.sh.temp"
integration_sh="integration.sh"

#定义去var文件中的变量函数，需要传递一个var文件中的变量
get_var() {
value=`cat $current_path/$var_file | grep -v "#" | grep $1 | awk -F "=" '{print $2}'`
if [ "$value" = "" ];then 
	return 2
else 
	echo  $value
fi
}



#--------------------------------------------------------------------------
#获取var文件中的所有变量
#--------------------------------------------------------------------------

url=`get_var  url`
if [ "$url" = "" ];then
	echo "未在$current_path/$var_file文件中找到url变量，程序退出！！！"
	exit 2
fi

#SOFT_FILE 获取ansible主机的安装包存放路径
SOFT_FILE=`get_var SOFT_FILE`
if [ "$SOFT_FILE" = "" ];then
        echo "未在$current_path/$var_file文件中找到SOFT_FILE变量，程序退出！！！"
        exit 2
fi


#---------------------------------------------------------------------------
#定义生成文件存放目录
doc="docs"

#ansible文件inventory
inventory="inventory"

#db info
dbinfo="dbinfo.yml"
#ansible配置文件
ansible_cfg="ansible.cfg"

#将inventory中的组提取出来
inventory_list="inventory_list"

#最新版本号
latest_version="latest_version.txt"

#本次安装版本号
install_version="install_version.txt"

#appname为安装的应用   
#appversion为对应应用的版本号

#定义下载包的前后缀
prefix="install_"
suffix=".tar.gz"


#定义docker ansible的下载地址
#docker_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/docker-19.03.8.tgz"
#ansible_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/ansible-2.5.1.tar"
#mysql_python_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/MySQL-python-1.2.5-1.el7.x86_64.rpm"
hymedia_url="http://d.devdemo.trs.net.cn/hy/hycloud-wget/hymedia/hymedia.tar.gz"
trsmedia_url="http://d.devdemo.trs.net.cn/hy/hycloud-wget/trsmedia/trsmedia.tar.gz"
ansible_tmp="/tmp/ansible_tmp"



#密码验证

#read -p "请输入ansible master主机的IP（直接回车默认本机）:"  ansible_ip
#if [ "$ansible_ip" != "" ];then
#	read -p "请输入ansible master主机的ssh端口（直接回车默认22）:"  ansible_port
#	if [ "$ansible_port" = "" ];then
#		ansible_port="22"
#	fi
#	echo -e "\033[31m请提前ssh -p $ansible_port $ansible_ip 取消远程登录时的“yes”认证。\033[0m"
#	read -s -p "请输入ansible master主机的root密码:"  ansible_pass
#	echo -e "\r"
#fi

#检测工程目录是否为空
#if [ "$ansible_ip" = ""  ];then
	mkdir -p $SOFT_FILE #&> /dev/null
	SOFT_FILE_numl=`ls $SOFT_FILE |wc -l`
	if [ "$SOFT_FILE_numl" != "0" ];then
		echo -e "当前的ansible工具下载目录\033[31m$SOFT_FILE\033[0m不为空，跳过下载程序。"
		exit 3
	fi	
#fi


#检测输入ansible账号密码是否正确
#if [ "$ansible_ip" != ""  ];then
#	date_check=`date "+%Y-%m-%d-%H-%M"`
#	echo "$date_check验证连接属性" >  $current_path/check.txt
#	sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/check.txt   root@$ansible_ip:/tmp/  &> /dev/null
#	
#	if [ $? != 0 ];then
#	        echo -e "\r"
#	        echo -e  "\033[33;5mansible主机连接失败，请检查IP、端口、root密码是否正确!\033[0m"
#	        exit 2
#	fi
#	rm -rf $current_path/check.txt
##检测工程目录是否为空
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_FILE; ls $SOFT_FILE | wc -l > /tmp/file_num"
#sshpass  -p "$ansible_pass" scp -P $ansible_port root@$ansible_ip:/tmp/file_num  /tmp
#file_num=`cat /tmp/file_num`
#	if [ "$file_num" != ""0 ];then
#        	echo -e "$ansible_ip的ansible执行目录\033[31m$SOFT_FILE\033[0m不为空，程序退出。"
#        	exit 2
#	fi
#fi


#提取inventory中所有组名
cat $current_path/$info/$inventory  | grep -v "#" | grep "\[" | grep  -v ":"  |  awk -F  "["  '{print $2}' | awk -F "]"   '{print $1}' > $current_path/$doc/$inventory_list
#对所有组名计数
install_num=`cat $doc/$inventory_list | wc -l`


#检测是否存在install_version准备好的安装版本
if [ -f $current_path/$doc/$install_version ];then
	echo -e "检测到自定义安装的版本文件：\033[32m$doc/$install_version\033[0m"

else
#将inventory中提取出的组名与最新版本号记录文件中的记录进行匹配，未找到提示跳过安装
	echo "docker:19.03.8" >> $current_path/$doc/$install_version
	echo "igses:2.3.3" >> $current_path/$doc/$install_version
	for i in `seq $install_num`
	do 
		appname=`cat $current_path/$doc/$inventory_list |  awk  "NR==$i {print}"`
		cat $current_path/$doc/$latest_version |grep -v "#" | grep $appname: >> $current_path/$doc/$install_version
	if [ $? != 0 ];then 
		if [ $appname == "ckm" ];then
			continue				
		fi
		echo -e "未找到\t$appname    的最新版本号，跳过安装。"
		continue
	fi
	done
fi

#创建临时下载目录,保证tmp目录干净
rm -rf $current_path/$file_tmp
mkdir -p $current_path/$file_tmp
rm -rf $current_path/$images_tmp
mkdir -p $current_path/$images_tmp

#下载docker ansible  的镜像 安装包
echo "-------------------- 海云 ansible 安装工具下载开始 --------------------"
echo "等待中......"
#wget $docker_url  -P  $current_path/$images_tmp  &> /dev/null
#wget $ansible_url  -P  $current_path/$images_tmp  &> /dev/null
#wget $mysql_python_url -P $current_path/$images_tmp  &> /dev/null
wget $hymedia_url -P $current_path/$images_tmp  &> /dev/null
        if [ $? == 0 ];then
        #echo "$wget_url下载失败。"
		echo "hymedia下载完成"
	else 
		echo "hymedia下载失败"
	fi
wget $trsmedia_url -P $current_path/$images_tmp  &> /dev/null
        if [ $? == 0 ];then
        #echo "$wget_url下载失败。"
                echo "trsmedia下载完成"
        else 
                echo "trsmedia下载失败"
        fi

date1=`date +%s`

echo "---------- 开始下载 ansible roles ----------"
echo "等待中......"
#将版本号和应用拆分，拼接为url并下载安装包
for app_version  in `cat $current_path/$doc/$install_version`
do
{
	appname=`echo $app_version | cut -d : -f 1`
	appversion=`echo $app_version | cut -d : -f 2`
	wget_url=$url/$appname/$appversion/$prefix$appname-$appversion$suffix
	wget_url_md5=$url/$appname/$appversion/$prefix$appname-$appversion$suffix.md5

	wget $wget_url  -P  $current_path/$file_tmp  &> /dev/null
	if [ $? != 0 ];then
	echo "$wget_url下载失败。"
	fi
	wget $wget_url_md5  -P  $current_path/$file_tmp  &> /dev/null
	if [ $? != 0 ];then
	echo "$wget_url_md5下载失败。"
	fi
}&

done
wait
date2=`date +%s`
let date3=date2-date1
echo "下载耗时 $date3 S"
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#本地安装
#下载主机为ansible控制机
#if [ "$ansible_ip" = "" ];then

#ansible环境安装工具
#rm -rf $ansible_tmp
mkdir -p $ansible_tmp
cp $current_path/$images_tmp/* $ansible_tmp

#检测本地是否有ansible docker安装环境
#bash $current_path/$scrips/$ansibletool_install_sh

#传输ansible自动化安装工具
#进行md5校验
date6=`date +%s`
echo "---------- 开始校验md5值，并解压 ----------"
echo "等待中......"
	cp $current_path/$file_tmp/*  $SOFT_FILE
	ls $SOFT_FILE/*.tar.gz > /tmp/tmp-hy

	for i in `cat /tmp/tmp-hy`
	do

#md5校验，并比较
{	md5_tmp=`md5sum  $i  |  awk '{print $1}'`
	md5_true=`cat $i.md5`
		if [ "$md5_tmp" != "$md5_true" ];then
			echo "$i的md5值为$md5_tmp,正确的md5值为$i.md5，请重新下载。"
			rm -rf $i
			rm -rf ${i}.md5
			continue
		else 
			#echo "$i的md5值正确。"
#解压
	        	tar -zxf  $i -C $SOFT_FILE
        		rm -rf $i
        		rm -rf ${i}.md5
			echo "$i的md5值正确。"
		
		 fi
}&
	done
wait
tar -zxf $ansible_tmp/hymedia.tar.gz -C $SOFT_FILE
tar -zxf $ansible_tmp/trsmedia.tar.gz -C $SOFT_FILE
date4=`date +%s`
let date5=date4-date6
echo "校验MD5值并解压耗时 $date5 S"

#合并roles目录
date7=`date +%s`
echo "---------- 开始合并 ansible roles 目录 ----------"
echo "等待中......"
	cd $SOFT_FILE
	install_tar=`ls -d install_*`
	echo $install_tar > /tmp/install_tar
	for i in `cat /tmp/install_tar`
	do
	/usr/bin/cp -r $SOFT_FILE/$i/* $SOFT_FILE &> /dev/null 
	if [ $? != 0 ] ;then
		echo "$i合并错误，请联系管理员"
	fi
	rm -rf $SOFT_FILE/$i
	done
#传递ansible.cfg配置文件
cp $current_path/$info/$ansible_cfg $SOFT_FILE
cp $current_path/$info/$inventory $SOFT_FILE/inventory-all
cp $current_path/$info/$dbinfo $SOFT_FILE
#删除下载目录
rm -rf $current_path/$tmp

date8=`date +%s`
let date9=date8-date7
echo "合并完成,耗时 $date9 S"

#fi



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#判断是否远程安装

#密码验证
while true
do
	read -p "本机是否为ansible控制机,Y代表是，N代表不是（Y/N）:"  ansible_ip
	if [ "$ansible_ip" == "Y" ] || [ "$ansible_ip" == "N" ];then
		break
	fi
done
#read -p "请输入ansible master主机的IP（直接回车默认本机）:"  ansible_ip
#if [ "$ansible_ip" != "" ];then
#        read -p "请输入ansible master主机的ssh端口（直接回车默认22）:"  ansible_port
#        if [ "$ansible_port" = "" ];then
#                ansible_port="22"
#        fi
#        echo -e "\033[31m请提前ssh -p $ansible_port $ansible_ip 取消远程登录时的“yes”认证。\033[0m"
#        read -s -p "请输入ansible master主机的root密码:"  ansible_pass
#        echo -e "\r"
#fi


#检测输入ansible账号密码是否正确
#if [ "$ansible_ip" != ""  ];then
#        date_check=`date "+%Y-%m-%d-%H-%M"`
#        echo "$date_check验证连接属性" >  $current_path/check.txt
#        sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/check.txt   root@$ansible_ip:/tmp/  &> /dev/null
#
#        if [ $? != 0 ];then
#                echo -e "\r"
#                echo -e  "\033[33;5mansible主机连接失败，请检查IP、端口、root密码是否正确!\033[0m"
#                exit 2
#        fi
#        rm -rf $current_path/check.txt
##检测工程目录是否为空
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_FILE; ls $SOFT_FILE | wc -l > /tmp/file_num"
#sshpass  -p "$ansible_pass" scp -P $ansible_port root@$ansible_ip:/tmp/file_num  /tmp
#file_num=`cat /tmp/file_num`
#        if [ "$file_num" != ""0 ];then
#                echo -e "$ansible_ip的ansible工具执行目录\033[31m$SOFT_FILE\033[0m不为空，请检查。"
#                exit 2
#        fi
#fi

if [ "$ansible_ip" == "N" ];then
#	echo "这不是ansible控制机"
#	echo $SOFT_FILE
	echo "---------- 开始打包 /TRS/HyCloud_devops、/TRS/hycloud_docker_autoinstall 目录 ----------"
	echo "等待中......"
	cd /TRS; tar -Pzcf  HyCloud_devops.tar.gz  $SOFT_FILE
        if [ $? == 0 ];then	
		echo -e "\n将 \033[31m/TRS/HyCloud_devops.tar.gz\033[0m 手动拷贝到ansible控制机的 \033[31m/TRS\033[0m 目录\n在ansible控制机执行命令：\033[32mcd /TRS; tar -Pzxf HyCloud_devops.tar.gz \033[0m解压。\n"
	fi	

	cd /TRS; tar -Pzcf  hycloud_docker_autoinstall.tar.gz  /TRS/hycloud_docker_autoinstall
	if [ $? == 0 ];then
		echo -e "\n将 \033[31m/TRS/hycloud_docker_autoinstall.tar.gz\033[0m 手动拷贝到ansible控制机的 \033[31m/TRS\033[0m 目录\n在ansible控制机执行命令：\033[32mcd /TRS; tar -Pzxf hycloud_docker_autoinstall.tar.gz \033[0m解压。\n"
	fi



##检测远程是否有ansible docker安装环境
#sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$scrips/$ansibletool_install_sh   root@$ansible_ip:/tmp  &> /dev/null
#if [ $? != 0 ];then
#                echo -e "\033[31m$scrips/$ansibletool_install_sh传输失败，请手动下载！\033[0m"
#fi
#
##传输环境的安装包
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "rm -rf $ansible_tmp; mkdir -p $ansible_tmp"
#sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$images_tmp/*  root@$ansible_ip:$ansible_tmp
#
##远程执行环境检测脚本，并回传检测结果
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "bash /tmp/$ansibletool_install_sh  > /tmp/$ansibletool_install_sh_result"
#sshpass  -p "$ansible_pass" scp -P $ansible_port root@$ansible_ip:/tmp/$ansibletool_install_sh_result $current_path 
#cat $current_path/$ansibletool_install_sh_result; rm -rf $current_path/$ansibletool_install_sh_result
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$file_tmp/* root@$ansible_ip:$SOFT_FILE
#
#
##对远程传输的ansible工具进行md5校验
#cp $current_path/$scrips/$md5_check_sh_tmp $current_path/$scrips/$md5_check_sh
#sed -i   s@\$SOFT_FILE@$SOFT_FILE@g  $scrips/$md5_check_sh
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$scrips/$md5_check_sh root@$ansible_ip:/tmp
#rm -rf $current_path/$scrips/$md5_check_sh
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "bash /tmp/$md5_check_sh > /tmp/md5_check"
##回传md5校验值
#sshpass  -p "$ansible_pass" scp -P $ansible_port root@$ansible_ip:/tmp/md5_check $current_path
#cat $current_path/md5_check; rm -rf $current_path/md5_check
#
##整合roles
#cp $current_path/$scrips/$integration_sh_tmp $current_path/$scrips/$integration_sh
#sed -i   s@\$SOFT_FILE@$SOFT_FILE@g  $scrips/$integration_sh
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$scrips/$integration_sh root@$ansible_ip:/tmp
#rm -rf $current_path/$scrips/$integration_sh
#sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "bash /tmp/$integration_sh"
##传递ansible.cfg配置文件
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$info/$ansible_cfg root@$ansible_ip:$SOFT_FILE
##传递inventory文件
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$info/$inventory root@$ansible_ip:$SOFT_FILE
##传递db info文件
#sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$info/$dbinfo root@$ansible_ip:$SOFT_FILE
##删除下载目录
#rm -rf $current_path/$tmp
fi

#说明生成文件的作用
echo -e "当前路径下的\t\033[32m$file/$doc/$install_version\033[0m\t为本次已安装的应用版本信息"
echo -e "当前路径下的\t\033[32m$file/$doc/$inventory_list\033[0m\t为本次应安装的应用集合"
echo -e "ansible工程目录：\033[31m$SOFT_FILE\033[0m"
