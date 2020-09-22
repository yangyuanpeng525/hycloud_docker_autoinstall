#!/usr/bin/env python2
#-*- coding: utf-8 -*-
import os
import re
import ConfigParser
from pprint import pprint 
import subprocess

BaseFolder=os.getcwd()

SectionDict={}


def ParseFile(filename=None):
    global SectionDict
    config = ConfigParser.ConfigParser()
    config.read(filename)

    TmpSectionList = config.sections()
    for section in TmpSectionList:
        section = section.strip()
        if ':var' in section:
            if section not in SectionDict:
                SectionDict[section] = list(config.items(section))
        else:
            if section not in SectionDict:
                SectionDict[section] = list(config.items(section))
                continue

            for option in config.items(section):
                SectionDict[section].append(option)


while True:
    ExcelFileName = raw_input('请输入部署信息表格名称(输入Q，退出程序):')
    ExcelFileName = ExcelFileName.strip()
    if ExcelFileName == 'Q' or ExcelFileName == 'q':
        exit (0)
     
    if not os.path.isfile(ExcelFileName):
        print ('当前目录未找到文件： '+str(ExcelFileName))
        continue

    print (ExcelFileName+'  文件存在，开始解析....')

    if not os.path.isdir(os.path.join(BaseFolder, 'tmp')):
        os.mkdir(os.path.join(BaseFolder, 'tmp'))
    
    subprocess.call('rm -f -r tmp/*', shell=True)


    subprocess.call('java -jar anallysisExcel.jar %s %s'%(ExcelFileName, os.path.join(BaseFolder, 'tmp')), shell=True)
    print (ExcelFileName+'  文件解析完成')

    break



for TmpBasePath,TmpFolders,TmpFiles in os.walk(os.path.join(BaseFolder, 'tmp')):
    if TmpBasePath != os.path.join(BaseFolder, 'tmp'):
        continue
    for file in TmpFiles:
        if 'inventory' not in file:
            continue
        ParseFile(os.path.join(TmpBasePath, file))


with open(os.path.join(BaseFolder, 'tmp', 'all-inventory'), mode='w') as f:
    for section in SectionDict:
        f.write('[%s]'%(section,)+'\n')
        for option in SectionDict[section]:
            f.write('='.join(option)+'\n')
        f.write('\n')


subprocess.call('rm -f Ansible_Install_HyCloud/info/inventory',shell=True)
subprocess.call('rm -f Ansible_Install_HyCloud/info/dbinfo.yaml',shell=True)

subprocess.call('cp tmp/dbinfo.yaml Ansible_Install_HyCloud/info/', shell=True)
subprocess.call('cp tmp/all-inventory Ansible_Install_HyCloud/info/inventory', shell=True)
