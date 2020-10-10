#!/bin/bash
#IPM
ipm_jar="/TRS/hycloud_media/IPM/*.jar"

ls ${ipm_jar} &>/dev/null


if [ $? == 0 ];then
   cp ${ipm_jar}  /TRS/HyCloud_devops/hymedia/ipm
if [ $? == 0 ];then
   echo "${ipm_jar} 检测成功"
fi
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

fi

ls ${iip_app} &>/dev/null


if [ $? == 0 ];then
   cp ${iip_app}  /TRS/HyCloud_devops/hymedia/iip
if [ $? == 0 ];then
   echo "${iip_app} 检测成功"
fi

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

fi

ls ${igi_app} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_app}  /TRS/HyCloud_devops/hymedia/igi
if [ $? == 0 ];then
   echo "${igi_app} 检测成功"
fi

fi



#IGS
igs_war="/TRS/hycloud_media/IGS/igs.war"

ls ${igs_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igs_war}  /TRS/HyCloud_devops/hymedia/igs
if [ $? == 0 ];then
   echo "${igs_war} 检测成功"
fi

fi


