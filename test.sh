#!/bin/bash

#获取当前的路径
current_path=`pwd`

#定义变量文件
var_file="var"

#定义存放ansible包的临时目录
file_tmp="tmp-hy-ansible"
images_tmp="tmp-images"

#ansible环境安装脚本
ansibletool_install_sh="ansibletool_install.sh"
#定义去var文件中的变量函数，需要传递一个var文件中的变量
get_var() {
value=`cat $current_path/$var_file | grep -v "#" | grep $1 | awk -F "=" '{print $2}'`
if [ "$value" = "" ];then 
	return 2
else 
	echo  $value
fi
}

#定义main.yml生成函数,需要传递一个参数
main_yml(){
tee <<EOF
- name: import $1 安装模块
  import_playbook: $1.yml
EOF
}

#--------------------------------------------------------------------------
#获取var文件中的所有变量
#--------------------------------------------------------------------------

#url 获取下载地址
#url="http://d.devdemo.trs.net.cn/hy/devops-hy"
#url=`cat $current_path/$var_file | grep -v "#" | grep url | awk -F "=" '{print $2}'`
#get_var  url
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
#ansible文件inventory
inventory="inventory"

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

#定义TRS 海云的role，用于生成trsapp_main.yaml hyapp_main.yaml
ids_role="install_ids"
ckm_role="install_ckm"
mas_role="install_mas"
wechat_role="install_wechat"
weibo_role="install_weibo"
echo "$ids_role $ckm_role $mas_role $wechat_role $weibo_role "

iip_role="install_iip"
igi_role="install_igi"
igs_role="install_igs"
ipm_role="install_ipm"
echo "$iip_role $igi_role $igs_role $ipm_role"

base_main_yaml="base_main.yaml"
trsapp_main_yaml="trsapp_main.yaml"
hyapp_main_yaml="hyapp_main.yaml"

all_yaml="main.yaml"

#定义docker ansible的下载地址
docker_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/docker-19.03.8.tgz"
ansible_url="http://d.devdemo.trs.net.cn/apollo/devops/tools/ansible-2.5.1.tar"
ansible_tmp="/tmp/ansible_tmp"



#密码验证

read -p "请输入ansible master主机的IP（直接回车默认本机）:"  ansible_ip
if [ "$ansible_ip" != "" ];then
	read -p "请输入ansible master主机的ssh端口（直接回车默认22）:"  ansible_port
	if [ "$ansible_port" = "" ];then
		ansible_port="22"
	fi
	echo -e "\033[31m请提前ssh -p $ansible_port $ansible_ip 取消“yes”认证。\033[0m"
	read -s -p "请输入ansible master主机的root密码:"  ansible_pass
fi




if [ "$ansible_ip" != ""  ];then
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
fi


#提取inventory中所有组名
cat $current_path/$inventory  | grep -v "#" | grep "\[" | grep  -v ":"  |  awk -F  "["  '{print $2}' | awk -F "]"   '{print $1}' > $current_path/$inventory_list
#对所有组名计数
install_num=`cat $inventory_list | wc -l`

#更新本次安装的版本记录文件
#> $current_path/$install_version

#检测是否存在install_version准备好的安装版本
if [ -f $current_path/$install_version ];then
	echo "检测到自定义安装的版本号"

else
#将inventory中提取出的组名与最新版本号记录文件中的记录进行匹配，未找到提示跳过安装
	for i in `seq $install_num`
	do 
		appname=`cat $current_path/$inventory_list |  awk  "NR==$i {print}"`
		cat $current_path/$latest_version |grep -v "#" | grep $appname: >> $current_path/$install_version
	if [ $? != 0 ];then 
		echo -e "未找到\t$appname    的最新版本号，跳过安装。"
		continue
	fi
	done
fi
#删除tmp文件记录组名的临时文件
#rm -rf $current_path/$inventory_list


#创建临时下载目录,保证tmp目录干净
echo -e "\r"
rm -rf $current_path/$file_tmp
mkdir $current_path/$file_tmp
rm -rf $current_path/$images_tmp
mkdir $current_path/$images_tmp

#下载docker ansible  的镜像 安装包
wget $docker_url  -P  $current_path/$images_tmp  &> /dev/null
wget $ansible_url  -P  $current_path/$images_tmp  &> /dev/null


#将版本号和应用拆分，拼接为url并下载安装包
for app_version  in `cat $current_path/$install_version`
do
	appname=`echo $app_version | cut -d : -f 1`
	appversion=`echo $app_version | cut -d : -f 2`
	wget_url=$url/$appname/$appversion/$prefix$appname-$appversion$suffix
	wget_url_md5=$url/$appname/$appversion/$prefix$appname-$appversion$suffix.md5
	wget $wget_url  -P  $current_path/$file_tmp  &> /dev/null
	wget $wget_url_md5  -P  $current_path/$file_tmp  &> /dev/null
done
#rm -rf $current_path/$install_version


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#本地安装
#下载主机为ansible控制机
if [ "$ansible_ip" = "" ];then
#检测本地是否有ansible docker安装环境
bash $current_path/$ansibletool_install_sh

#ansible环境安装工具
rm -rf $ansible_tmp
mkdir -p $ansible_tmp
cp $current_path/$images_tmp/* $ansible_tmp

#传输ansible自动化安装工具
#进行md5校验
	mkdir -p $SOFT_FILE #&> /dev/null
	SOFT_FILE_numl=`ls $SOFT_FILE |wc -l`
	if [ "$SOFT_FILE_numl" != "0" ];then
		echo "ansible执行目录$SOFT_FILE不为空，退出下载程序。"
		exit 3
	fi
	cp $current_path/$file_tmp/*  $SOFT_FILE
	ls $SOFT_FILE/*.tar.gz > /tmp/tmp-hy

	for i in `cat /tmp/tmp-hy`
	do
#md5校验，并比较
	md5_tmp=`md5sum  $i  |  awk '{print $1}'`
	md5_true=`cat $i.md5`
		if [ "$md5_tmp" != "$md5_true" ];then
			echo "$i的md5值为$md5_tmp,正确的md5值为$i.md5，请重新下载。"
			continue
		else 
			echo "$i的md5值正确。"
#解压
	        	tar -zxf  $i -C $SOFT_FILE
        		rm -rf $i
        		rm -rf $i.md5
		fi
	done
#合并roles目录
#	mkdir -p $SOFT_FILE/roles #&> /dev/null
	cd $SOFT_FILE
	install_tar=`ls -d install_*`
	echo $install_tar > /tmp/install_tar
	cp -r $SOFT_FILE/$install_tar/* $SOFT_FILE
	rm -rf $SOFT_FILE/$install_tar

#main.yaml
	cd $SOFT_FILE/roles
	install_role=`ls -d *`
	echo $install_role > /tmp/install_role

#生成trsapp_main.yml hyapp_main.yaml
	for i in `cat /tmp/install_role`
	do
	if [ "$i" = "$ids_role" ] || [ "$i" = "$ckm_role" ] || [ "$i" = "$mas_role" ] || [ "$i" = "$wechat_role" ] || [ "$i" = "$weibo_role" ];then
#TRS的trsapp_main_yaml
	main_yml $i >> $SOFT_FILE/$trsapp_main_yaml
	continue
	fi	
	if [ "$i" = "$iip_role" ] || [ "$i" = "$igi_role" ] || [ "$i" = "$igs_role" ] || [ "$i" = "$ipm_role" ];then
#海云的hyapp_main_yaml
	main_yml $i >> $SOFT_FILE/$hyapp_main_yaml
	continue
	fi
#基础的base_main_yaml
	main_yml $i >> $SOFT_FILE/$base_main_yaml
	done 

#生成main.yaml
	if [ -f $SOFT_FILE/$base_main_yaml ];then
		main_yml base_main_yaml >> $SOFT_FILE/$all_yaml
	fi
	if [ -f $SOFT_FILE/$trsapp_main_yaml ];then
		main_yml trsapp_main_yaml >> $SOFT_FILE/$all_yaml
	fi
	if [ -f $SOFT_FILE/$hyapp_main_yaml ];then
		main_yml hyapp_main_yaml >> $SOFT_FILE/$all_yaml
	fi
fi





#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#远程安装
if [ "$ansible_ip" != "" ];then

fi












echo -e "当前路径下的\t$install_version\t为本次安装的应用版本信息"
echo -e "当前路径下的\t$inventory_list\t为本次安装的所用应用集合"
