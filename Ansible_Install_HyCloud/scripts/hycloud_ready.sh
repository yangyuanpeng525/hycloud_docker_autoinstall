#!/bin/bash
#IPM
ipm_jar="/TRS/hycloud_media/IPM/*.jar"

ls ${ipm_jar} &>/dev/null


if [ $? == 0 ];then
   cp ${ipm_jar}  /TRS/HyCloud_devops/hymedia/ipm
fi





#IIP
iip_war="/TRS/hycloud_media/IIP/gov.war"
iip_app="/TRS/hycloud_media/GOVAPP/govapp.tar.gz"

ls ${iip_war} &>/dev/null


if [ $? == 0 ];then
   cp ${iip_war}  /TRS/HyCloud_devops/hymedia/iip
fi

ls ${iip_app} &>/dev/null


if [ $? == 0 ];then
   cp ${iip_app}  /TRS/HyCloud_devops/hymedia/iip
fi


#IGI
igi_war="/TRS/hycloud_media/IGI/IGI.war"
igi_app="/TRS/hycloud_media/IGI-APP/interaction.tar.gz"

ls ${igi_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_war}  /TRS/HyCloud_devops/hymedia/igi
fi

ls ${igi_app} &>/dev/null


if [ $? == 0 ];then
   cp ${igi_app}  /TRS/HyCloud_devops/hymedia/igi
fi



#IGS
igs_war="/TRS/hycloud_media/IGS/igs.war"

ls ${igs_war} &>/dev/null


if [ $? == 0 ];then
   cp ${igs_war}  /TRS/HyCloud_devops/hymedia/igs
fi


