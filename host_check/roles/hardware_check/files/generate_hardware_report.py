#!/usr/bin/env python2
# -*- coding:utf-8 -*-

import os
import sys
import re

TmpSearchBasePath = sys.argv[1]
ReportTxtFile = open(TmpSearchBasePath + '/../report/hardware_check_result_report.txt', mode='w')

TmpFaildResult = []
TmpPassedResult = []
TmpIPList = []

TmpTargetFilesPath = []
for basepath, dirs, files in os.walk(TmpSearchBasePath):
    if basepath != TmpSearchBasePath:
        continue

    for file in files:
        if not file.endswith(r'_hardware_check_result.log'):
            continue

        IPInfo = file.replace('_hardware_check_result.log', '').replace('_', '.')
        if IPInfo in TmpIPList:
            continue
        TmpIPList.append(IPInfo)

        with open(TmpSearchBasePath + '/' + file, mode='r') as f:
            TmpContent = f.read()

        if 'bad' in TmpContent:
            TmpFaildResult.append(IPInfo + ' ' + TmpContent)
        else:
            TmpPassedResult.append(IPInfo + ' ' + TmpContent)

for item in TmpFaildResult + TmpPassedResult:
    ReportTxtFile.write(item + '\n')
ReportTxtFile.close()

ChineseNameMapping = {'MinCPUCore': 'CPU核心数', 'MinMemSize': '内存大小', 'MinDiskSize': '磁盘容量', 'MinDiskIOSpeed': '磁盘IO',
                      'FolderMustExist': '目录检测'}

TmpHTMLContent = ''
with open(TmpSearchBasePath + '/../report/hardware_check_result_report.txt', mode='r') as f:
    for line in f:
        line = line.strip()
        TmpList = line.split()
        if not line:
            continue

        TableRowBackgroundColorTag = r'<tr style="background-color: white;">'
        if '异常' in TmpList[1]:
            TableRowBackgroundColorTag = r'<tr style="background-color: yellow;">'

        TmpHTMLContent += '<tr>%s<th>%s</th><th>%s</th>' % (TableRowBackgroundColorTag, TmpList[0], TmpList[1].replace(r'summary:', ''))

        for subitem in TmpList[2:]:
            TmpItemName, TmpItemTargetValue, TmpItemRealValue, TmpItemDesc, TmpItemOther = subitem.split(':')
            TmpHTMLContent += '<th>%s</th><th>%s</th><th>%s</th><th>%s</th>' % (
            ChineseNameMapping[TmpItemName], TmpItemTargetValue, TmpItemRealValue, TmpItemDesc)
        TmpHTMLContent += r'</tr>'

TmpTemplateContent = ''
with open(r'hardware_check_result_report.html.template', mode='r') as f:
    TmpTemplateContent = f.read()
    TmpTemplateContent = TmpTemplateContent.replace(r'{replace_me_here}', TmpHTMLContent)

with open(TmpSearchBasePath + '/../report/hardware_check_result_report.html', mode='w') as f:
    f.write(TmpTemplateContent)

if len(TmpFaildResult) > 0:
    exit(1)

exit(0)
