#!/usr/bin/env python2
#-*- coding:utf-8 -*-

import os
import sys
import re

TmpSearchBasePath=sys.argv[1]
ReportTxtFile=open(TmpSearchBasePath+'/../report/port_check_result_report.txt', mode='w')

TmpFaildResult=[]
TmpPassedResult=[]
TmpIPList=[]

TmpTargetFilesPath=[]
for basepath,dirs,files in os.walk(TmpSearchBasePath):
  if basepath != TmpSearchBasePath:
    continue

  for file in files:
    if not file.endswith(r'_port_check_result.log'):
      continue
 
    IPInfo=file.replace('_port_check_result.log', '').replace('_', '.')
    if IPInfo in TmpIPList:
      continue
    TmpIPList.append(IPInfo)
     
    with open(TmpSearchBasePath+'/'+file, mode='r') as f:
      for  TmpContent in f:
        if 'bad'  in TmpContent:
          TmpFaildResult.append(TmpContent)
        else:
          TmpPassedResult.append(TmpContent)
     

for item in TmpFaildResult+TmpPassedResult:
    ReportTxtFile.write(item+'\n')
ReportTxtFile.close()


TmpHTMLContent=''
with open(TmpSearchBasePath+'/../report/port_check_result_report.txt', mode='r') as f:
   for line in f:
      line=line.strip()
      TmpList=line.split()
      if not line:
         continue

      TableRowBackgroundColorTag=r'<tr style="background-color: white;">'
      if '超时'  in  TmpList[0]:
        TableRowBackgroundColorTag=r'<tr style="background-color: yellow;">'

      TmpHTMLContent+='<tr>%s<th>%s</th><th>%s</th><th>%s</th><th>%s</th>'%(TableRowBackgroundColorTag,TmpList[1],TmpList[2],TmpList[3],TmpList[0].replace(r'summary:',''))
      
      TmpHTMLContent+=r'</tr>'


TmpTemplateContent=''
with open(r'port_check_result_report.html.template',mode='r') as f:
  TmpTemplateContent=f.read()
  TmpTemplateContent=TmpTemplateContent.replace(r'{replace_me_here}',TmpHTMLContent)  


with open(TmpSearchBasePath+'/../report/port_check_result_report.html',mode='w') as f:
  f.write(TmpTemplateContent)

if len(TmpFaildResult) >0:
  exit (1)

exit (0)
