#!/usr/bin/env python2
#-*- coding:utf-8 -*-

import os
import sys
import re

TmpSearchBasePath=sys.argv[1]

TmpHTMLContent=''
OutputHTMLContent=''

with open(TmpSearchBasePath+'/../report/hardware_check_result_report.html',mode='rb') as f:
   TmpHTMLContent=f.read()

TmpReObj=re.search(r'<h1>.*?</table>', TmpHTMLContent, flags=re.MULTILINE|re.DOTALL)

OutputHTMLContent=OutputHTMLContent+TmpReObj.group(0)


with open(TmpSearchBasePath+'/../report/port_check_result_report.html',mode='rb') as f:
   TmpHTMLContent=f.read()

TmpReObj=re.search(r'<h1>.*?</table>', TmpHTMLContent, flags=re.MULTILINE|re.DOTALL)

OutputHTMLContent+=TmpReObj.group(0)

TmpTemplateContent=''
with open(r'hosts_check_result_report.html.template', mode='r') as f:
  TmpTemplateContent = f.read()
  OutputHTMLContent=TmpTemplateContent.replace(r'{replace_me_here}', OutputHTMLContent)

with open(TmpSearchBasePath+'/../report/hosts_check_result_report.html',mode='w') as f:
  f.write(OutputHTMLContent)




exit (0)
