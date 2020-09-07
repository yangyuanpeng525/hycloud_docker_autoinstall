#!/bin/bash
#获取当前的路径
current_path=`pwd`

#定义海云需要安装的清单
images_list="install_hy_list.txt"
 
#定义安装ansible tool的脚本
script_ansible_tool="ansibletool_install.sh"

#定义安装ansible tool的安装结果文件
script_ansible_tool_result="install_ansible_tool_result.txt"

#定义存放ansible包的临时目录
file_tmp="tmp-hy-ansible"
images_tmp="tmp-images"

#定义ansible master主机镜像存放路径
SOFT_FILE="/TRS/ansible-hy"
IMAGE_FILE="/TRS/images-hy"

#定义镜像的下载地址
#wget_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/"
wget_url="http://d.devdemo.trs.net.cn/hy/devops-hy/"

#定义ansible包后缀
suffix=".tar.gz"

##定义WeChat、ckm压缩包名
#wechat_bag="WECHAT.zip"
#ckm_bag="TRSCKM2017.tar.gz"

#定义docker ansible下载地址
docker_bag="http://d.devdemo.trs.net.cn/hy/devops-hy/docker-19.03.8.tgz"
ansible_bag="http://d.devdemo.trs.net.cn/hy/devops-hy/ansible-2.5.1.tar"


read -p "请输入ansible master主机的IP:"  ansible_ip
read -p "请输入ansible master主机的ssh端口:"  ansible_port
read -s -p "请输入ansible master主机的root密码:"  ansible_pass

#检测expect工具
expect  -version &> /dev/null

if [ $? != 0 ];then
	yum -y install expect 
fi

#取消ssh登录的yes确认
expect  &> /dev/null <<EOF
spawn ssh -p $ansible_port  root@$ansible_ip  "echo hello"
expect {
        "*yes/no*"
                {send "yes\r";exp_continue;}
        "*password*"
                {send "$ansible_pass\r"}
} 
EOF

#检测ansible账号密码是否正确
date_check=`date "+%Y-%m-%d-%H-%M"`
echo "$date_check验证连接属性" >  $current_path/check.txt
sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/check.txt   root@$ansible_ip:/tmp/  &> /dev/null

if [ $? != 0 ];then
      	echo -e "\r"
	echo -e  "\033[33;5mansible主机连接失败，请检查IP、端口、root密码是否正确!\033[0m"
	exit 2
fi



#创建临时下载目录,保证tmp目录干净
echo -e "\r"
rm -rf $current_path/$file_tmp  
mkdir $current_path/$file_tmp
rm -rf $current_path/$images_tmp 
mkdir $current_path/$images_tmp 

#检测下载清单是否存在

if [ ! -f $current_path/$images_list  ];then
	echo -e  "\033[31m下载清单 $current_path/$images_list 不存在，请确认。\033[0m"
	exit 3
fi

#下载docker ansible安装包

#echo -e  "\033[31m镜像本地存放路径:$current_path/$images_tmp\033[0m"
        wget $docker_bag  -P  $current_path/$images_tmp &> /dev/null
        if [ $? != 0 ];then
                echo -e  "\033[31m$docker_bag下载失败，请手动下载。\033[0m"   
#        else
#                echo -e  "\033[32m$docker_bag已经完成下载。\033[0m"       
        fi

        wget $ansible_bag  -P  $current_path/$images_tmp &> /dev/null
        if [ $? != 0 ];then
                echo -e  "\033[31m$ansible_bag下载失败，请手动下载。\033[0m"   
#        else
#                echo -e  "\033[32m$ansible_bag已经完成下载。\033[0m"       
        fi


#下载ansible的tar.gz文件

echo -e  "\033[31mansible自动化安装包本地存放路径:$current_path/$file_tmp\033[0m"
for i in `cat $current_path/$images_list  | grep  -v "#"`	
do
if [ $i == "ckm" ];then
	wget $wget_url$ckm_bag  -P  $current_path/$file_tmp &> /dev/null
	if [ $? != 0 ];then
		echo -e  "\033[31m$ckm_bag下载失败，请手动下载。\033[0m"   
	else 
		echo -e  "\033[32m$ckm_bag已经完成下载。\033[0m"	
	fi
 	continue
fi
if [ $i == "wechat" ];then
	wget $wget_url$wechat_bag  -P  $current_path/$file_tmp &> /dev/null
	if [ $? != 0 ];then
		echo -e  "\033[31m$ckm_bag下载失败，请手动下载。\033[0m"   
	else 
		echo -e  "\033[32m$wechat_bag已经完成下载。\033[0m"	
	fi
 	continue
fi
	wget $wget_url$i$suffix -P  $current_path/$file_tmp  &> /dev/null
	if [ $? != 0 ];then
		echo -e  "\033[31m$ckm_bag下载失败，请手动下载。\033[0m"   
	else 
		echo -e  "\033[32m$i$suffix已经完成下载。\033[0m"	
	fi
done

#创建ansible master主机ansible包tar.gz存放目录
ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_FILE"
ssh -p $ansible_port root@$ansible_ip "mkdir -p $IMAGE_FILE"

#将本地的tar包导入ansible master主机

#echo -e  "\033[31m开始传输镜像到$ansible_ip(ansible)的$IMAGE_FILE目录。\033[0m"
for i in `ls $current_path/$images_tmp`
do
#判断镜像包是否存在
        if [ ! -f  "$current_path/$images_tmp/$i" ];then
                echo -e "\033[31m$current_path/$file_tmp中没有$i文件，请手动下载！\033[0m"
                continue
        fi

        sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$images_tmp/$i   root@$ansible_ip:$IMAGE_FILE  &> /dev/null

        if [ $? != 0 ];then
                echo -e "\033[31m$i传输失败，请手动下载！\033[0m"
#        else
#                echo -e "\033[32m$i传输成功。\033[0m"

fi
done








echo -e  "\033[31m开始传输ansible自动化安装包到$ansible_ip(ansible)的$SOFT_FILE目录。\033[0m"
for i in `ls $current_path/$file_tmp`
do
#判断镜像包是否存在
	if [ ! -f  "$current_path/$file_tmp/$i" ];then
		echo -e "\033[31m$current_path/$file_tmp中没有$i文件，请手动下载！\033[0m"
		continue
	fi

	sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$file_tmp/$i   root@$ansible_ip:$SOFT_FILE  &> /dev/null

	if [ $? != 0 ];then
		echo -e "\033[31m$i传输失败，请手动下载！\033[0m"
		continue
	else 
        	echo -e "\033[32m$i传输成功。\033[0m"
	ssh -p $ansible_port root@$ansible_ip "cd $SOFT_FILE;tar -zxf $i"

fi
done


#为ansible主机安装ansible工具
sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$script_ansible_tool   root@$ansible_ip:/tmp  &> /dev/null
ssh -p $ansible_port root@$ansible_ip "/tmp/$script_ansible_tool  > /root/$script_ansible_tool_result"
#回传安装结果
sshpass  -p "$ansible_pass" scp -P $ansible_port    root@$ansible_ip:/root/$script_ansible_tool_result  $current_path  &> /dev/null
echo -e "\033[33m输出$ansible_ip(ansible)主机的ansible安装结果！\033[0m"
cat  $current_path/$script_ansible_tool_result
