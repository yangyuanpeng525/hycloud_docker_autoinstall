#!/bin/bash
#IPM
ipm_jar="/TRS/hycloud_media/IPM/wcm-gov-kpi-0.0.1-SNAPSHOT.jar"

ls ${ipm_jar} &>/dev/null


if [ $? == 0 ];then
   cp ${ipm_jar}  /TRS/HyCloud_devops/hymedia/ipm
	if [ $? == 0 ];then
   	echo "${ipm_jar} 检测成功"
	fi
else
   echo "${ipm_jar} 未找到"

fi





#IIP
iip_war="/TRS/hycloud_media/IIP/gov.war"
iip_app="/TRS/hycloud_media/GOVAPP/govapp.tar.gz"

ls ${iip_war} &>/dev/null


if [ $? == 0 ];then
   cp ${iip_war}  /TRS/HyCloud_devops/hymedia/iip
	if [ $? == 0 ];then
   		echo "${iip_war} 检测成功"
	fi

else
   echo "${iip_war} 未找到"

fi

ls ${iip_app} &>/dev/null


if [ $? == 0 ];then
   cp ${iip_app}  /TRS/HyCloud_devops/hymedia/iip
	if [ $? == 0 ];then
   		echo "${iip_app} 检测成功"
	fi
else
   echo "${iip_app} 未找到"

fi


#IGI
igi_war="/TRS/hycloud_media/IGI/IGI.war"
igi_app="/TRS/hycloud_media/IGI-APP/interaction.tar.gz"

ls ${igi_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_war}  /TRS/HyCloud_devops/hymedia/igi
	if [ $? == 0 ];then
   		echo "${igi_war} 检测成功"
	fi
else
   echo "${igi_war} 未找到"

fi

ls ${igi_app} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_app}  /TRS/HyCloud_devops/hymedia/igi
	if [ $? == 0 ];then
   		echo "${igi_app} 检测成功"
	fi

else
   echo "${igi_app} 未找到"
fi



#IGS
igs_war="/TRS/hycloud_media/IGS/igs.war"

ls ${igs_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igs_war}  /TRS/HyCloud_devops/hymedia/igs
	if [ $? == 0 ];then
   		echo "${igs_war} 检测成功"
	fi
else
   echo "${igs_war} 未找到"

fi


#IGI-NET
igi_net_war="/TRS/hycloud_media/IGI-NET/IGI.war"
igi_net_app="/TRS/hycloud_media/IGI-NET-APP/IGI-NET-APP.tar.gz"

ls ${igi_net_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_net_war}  /TRS/HyCloud_devops/hymedia/igi
        if [ $? == 0 ];then
                echo "${igi_net_war} 检测成功"
        fi
else
   echo "${igi_net_war} 未找到"

fi

ls ${igi_net_app} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_net_app}  /TRS/HyCloud_devops/hymedia/igi
        if [ $? == 0 ];then
                echo "${igi_net_app} 检测成功"
        fi

else
   echo "${igi_net_app} 未找到"
fi

echo -e "\n --------------检查介质目录--------------"
ls /TRS/hycloud_media/*

while true
do
	read -p "确认以上是否为本次安装的全部介质，Y代表是，N代表不是（Y/N）:"  choose
        if [ "$choose" == "Y" ];then
	  break
	  exit 0
        fi
        if [ "$choose" == "N" ];then
          echo "请联系管理员核对介质！！！"
          exit 233
        fi
done 


