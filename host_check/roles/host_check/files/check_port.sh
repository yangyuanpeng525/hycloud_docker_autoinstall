#!/bin/bash

self_ip=$1
output_file="${self_ip//./_}_port_check_result.log"
rm -f  ${output_file}

while read line
do
   if [ -z "${line}" ]
   then
      continue
   fi
   
   current_ip=$(echo "${line}"|awk '{print $1}')
   target_ip_port=$(echo "${line}"|awk '{print $2" "$3}')

   if [ "${current_ip}" != "${self_ip}" ]
   then
       continue
   fi
   
   sleep 2


   ret_content=$(timeout --signal=9 8 echo -e '\x1dclose\x0d' | telnet ${target_ip_port} 2>&1)
   retcode='1'

   if [[ "${ret_content}" =~ .*Escape.* ]]
   then
       retcode=0
   fi



   if [[ "${retcode}" == 0 ]]
   then
       echo "summary:端口测试正常  ${line} good" >>${output_file}
   else
       echo "summary:端口连接超时,或者无法连接  ${line} bad" >>${output_file}
   fi



done < port_check_list.txt
