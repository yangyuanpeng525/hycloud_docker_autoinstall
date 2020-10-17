#!/usr/bin/env python2
# -*- coding: utf-8 -*-

GroupNameDict={}
with open(r'../../../tmp/groupname_2_hosts.log', mode='r') as f:
  for line in f:
     line=line.strip()
     if not line:
         continue
     tmplist=line.split()
     groupname=tmplist[0].strip()
     host=tmplist[1].strip()

     if groupname not in GroupNameDict:
       GroupNameDict[groupname]=[host]
       continue
     
     GroupNameDict[groupname].append(host)

TmpOutput=open(r'../../../tmp/port_check_list.txt',mode='w')
TmpOutput1=open(r'../../../tmp/host_listening_ports.txt',mode='w')

with open(r'service_dependency.txt',mode='r') as f:
  for line in f:
     line=line.strip()
     ###忽略注释行，或空行  ##
     if '#'  in line or not line:
        continue

     SrcGroup,DstGroup,Port=line.split()
     if (SrcGroup not in GroupNameDict) or (DstGroup not in GroupNameDict):
        continue    

     for srcip in GroupNameDict[SrcGroup]:
       for dstip in GroupNameDict[DstGroup]:
         TmpOutput.write(srcip+' '+dstip+' '+Port+'\n')
         TmpOutput1.write(dstip+' '+Port+'\n')
        
TmpOutput.close()
TmpOutput1.close()
