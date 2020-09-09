#!/bin/bash
#定义镜像的下载地址
wget_url="http://d.devdemo.trs.net.cn/hy/devops-hy/"


#获取当前的路径
current_path=`pwd`

#定义海云需要安装的清单
images_list="install_hy_list.txt"
 
#定义安装ansible tool的脚本
script_ansible_tool="ansibletool_install.sh"

#定义合并ansibel目录的脚本
integration_sh="integration.sh"

#定义安装ansible tool的安装结果文件
script_ansible_tool_result="install_ansible_tool_result.txt"

#定义存放ansible包的临时目录
file_tmp="tmp-hy-ansible"
images_tmp="tmp-images"

#定义ansible master主机镜像存放路径
SOFT_FILE="/TRS/ansible-hy"
SOFT_base_FILE="/TRS/ansible-hy/AutoInstall"
SOFT_hy_FILE="/TRS/ansible-hy/hyapp"
SOFT_trs_FILE="/TRS/ansible-hy/trsapp"
IMAGE_FILE="/TRS/ansible-hy/images-hy"

#定义ansible包前后缀
prefix="install_"
suffix=".tar.gz"

#定义docker ansible的固定下载地址下载地址
docker_bag="http://d.devdemo.trs.net.cn/hy/devops-hy/docker-19.03.8.tgz"
ansible_bag="http://d.devdemo.trs.net.cn/hy/devops-hy/ansible-2.5.1.tar"

#定义trs应用 海云应用用于将ansible包分类
ids_bag="ids"
ckm_bag="ckm"
mas_bag="mas"
wechat_bag="wechat"
weibo_bag="weibo"

iip_bag="iip"
igi_bag="igi"
igs_bag="igs"
ipm_bag="ipm"

#定义第三方应用 trs应用 海云应用的三个main.yml
base_yml="base.yml"
trs_yml="trs.yml"
hy_yml="hy.yml"

#定义main.yml生成函数
main_yml(){
tee <<EOF
- name: import $1
  import_playbook: $1.yml
EOF
}

#-------------------------------开始----------------------------------------------------
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
rm -rf $current_path/check.txt


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

echo -e  "\033[32m-----------------下载开始-----------------------\033[0m"
#下载docker ansible安装包
        wget $docker_bag  -P  $current_path/$images_tmp &> /dev/null
        if [ $? != 0 ];then
                echo -e  "\033[31m$docker_bag下载失败，请手动下载。\033[0m"   
        fi

        wget $ansible_bag  -P  $current_path/$images_tmp &> /dev/null
        if [ $? != 0 ];then
                echo -e  "\033[31m$ansible_bag下载失败，请手动下载。\033[0m"   
        fi


#下载ansible的tar.gz文件

echo -e  "\033[31mansible自动化安装包本地存放路径:$current_path/$file_tmp。\033[0m"
for i in `cat $current_path/$images_list  | grep  -v "#"`	
do
	wget $wget_url$prefix$i$suffix -P  $current_path/$file_tmp  &> /dev/null
	if [ $? != 0 ];then
		echo -e  "\033[31m$ckm_bag下载失败，请手动下载。\033[0m"   
	else 
		echo -e  "\033[32m$prefix$i$suffix已经完成下载。\033[0m"	
	fi

#生成main.yml文件
#trs
	if [ "$i" = "ids" ] || [ "$i" = "ckm" ]  || [ "$i" = "mas" ]  || [ "$i" = "wechat" ] || [ "$i" = "weibo" ];then
		main_yml $i >> $current_path/$trs_yml	
		continue	

	fi

#hy
        if [ "$i" = "iip" ] || [ "$i" = "igi" ]  || [ "$i" = "igs" ]  || [ "$i" = "ipm" ];then
		main_yml $i >> $current_path/$hy_yml
		continue
	fi
	main_yml $i >> $current_path/$base_yml
done

#创建ansible master主机ansible包tar.gz存放目录
sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_base_FILE"
sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_trs_FILE"
sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $SOFT_hy_FILE"
sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "mkdir -p $IMAGE_FILE"

#将本地的tar包导入ansible master主机
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

fi
done


#传输ansible包
echo -e  "\033[31m开始传输ansible自动化安装包到$ansible_ip(ansible)的$SOFT_FILE目录。\033[0m"
for i in `ls $current_path/$file_tmp`
do
#判断包是否存在
	if [ ! -f  "$current_path/$file_tmp/$i" ];then
		echo -e "\033[31m$current_path/$file_tmp中没有$i文件，请手动下载！\033[0m"
		continue
	fi


#区分应用分类
#trs应用
        if [ "$i" = "$prefix$ids_bag$suffix" ] || [ "$i" = "$prefix$ckm_bag$suffix" ]  || [ "$i" = "$prefix$mas_bag$suffix" ]  || [ "$i" = "$prefix$wechat_bag$suffix" ] || [ "$i" = "$prefix$weibo_bag$suffix" ];then
        sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$file_tmp/$i   root@$ansible_ip:$SOFT_trs_FILE  &> /dev/null
	        if [ $? != 0 ];then
        	        echo -e "\033[31m$i传输失败，请手动下载！\033[0m"
        	else
                	echo -e "\033[32m$i传输成功。\033[0m"
#解压trs应用
			sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "cd $SOFT_trs_FILE; tar -zxf $i; rm -rf $i"
		fi
	continue
	fi
##hy应用
        if [ "$i" = "$prefix$iip_bag$suffix" ] || [ "$i" = "$prefix$igi_bag$suffix" ]  || [ "$i" = "$prefix$igs_bag$suffix" ]  || [ "$i" = "$prefix$ipm_bag$suffix" ];then
        sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$file_tmp/$i   root@$ansible_ip:$SOFT_hy_FILE  &> /dev/null
                if [ $? != 0 ];then
                        echo -e "\033[31m$i传输失败，请手动下载！\033[0m"
                else
                        echo -e "\033[32m$i传输成功。\033[0m"
#解压hy应用
        		sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "cd $SOFT_hy_FILE;tar -zxf $i; rm -rf $i"
                fi
	continue
        fi

#基础应用
	sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$file_tmp/$i   root@$ansible_ip:$SOFT_base_FILE  &> /dev/null

	if [ $? != 0 ];then
		echo -e "\033[31m$i传输失败，请手动下载！\033[0m"
		continue
	else 
        	echo -e "\033[32m$i传输成功。\033[0m"

#解压
	sshpass  -p "$ansible_pass"	ssh -p $ansible_port root@$ansible_ip "cd $SOFT_base_FILE;tar -zxf $i; rm -rf $i"

fi
done

#整合目录
#trs
#sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "cd $SOFT_trs_FILE &&  ls | grep install > $SOFT_trs_FILE/trs.txt &&  for i in `cat $SOFT_trs_FILE/trs.txt`;  do  /bin/cp -rf  $i/* .; done"
#
##hy
#sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "cd $SOFT_hy_FILE && ls | grep install > $SOFT_hy_FILE/hy.txt &&  for i in `cat $SOFT_hy_FILE/hy.txt`; do  /bin/cp -rf  $i/* .; done"
#
##基础
#sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "cd $SOFT_base_FILE && ls | grep install > $SOFT_base_FILE/base.txt &&  for i in `cat $SOFT_base_FILE/base.txt` ; do  /bin/cp -rf  $i/* .; done"
#
sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$integration_sh   root@$ansible_ip:/tmp
sshpass  -p "$ansible_pass"     ssh -p $ansible_port root@$ansible_ip "bash /tmp/$integration_sh"

#传输基础main.yml
	if [ -f $current_path/$base_yml ];then
		sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$base_yml   root@$ansible_ip:$SOFT_base_FILE/main.yml
		rm -rf $current_path/$base_yml
	fi
#传输trs main.yml
	if [ -f $current_path/$trs_yml ];then
		sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$trs_yml   root@$ansible_ip:$SOFT_trs_FILE/main.yml
		rm -rf $current_path/$trs_yml
	fi
#传输hy main.yml
	if [ -f $current_path/$hy_yml ];then
		sshpass  -p "$ansible_pass" scp -P $ansible_port $current_path/$hy_yml   root@$ansible_ip:$SOFT_hy_FILE/main.yml
		rm -rf $current_path/$hy_yml
	fi

#为ansible主机安装ansible工具
sshpass  -p "$ansible_pass" scp -P $ansible_port  $current_path/$script_ansible_tool   root@$ansible_ip:/tmp  &> /dev/null
sshpass  -p "$ansible_pass" ssh -p $ansible_port root@$ansible_ip "/tmp/$script_ansible_tool  > /root/$script_ansible_tool_result"


#回传安装结果
sshpass  -p "$ansible_pass" scp -P $ansible_port    root@$ansible_ip:/root/$script_ansible_tool_result  $current_path  &> /dev/null
echo -e "\033[33m$ansible_ip(ansible)主机的ansible安装结果！\033[0m"
cat  $current_path/$script_ansible_tool_result
rm -rf $current_path/$script_ansible_tool_result
