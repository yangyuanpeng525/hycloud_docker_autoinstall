#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import subprocess
import socket
import threading
from time import sleep
import sys
import os

def checkPortState(host='127.0.0.1',port=9200):
### 检查对应服务器上面的port 是否处于TCP监听状态 ##

    s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.settimeout(1)
    try:
       s.connect((host,port))
       return {'RetCode':0,
               'Result':str(host)+':'+str(port)+'处于监听状态'}
    except:
       return {'RetCode':1,
               'Result':'无法访问'+str(host)+':'+str(port)}


def configFireallRule(port):
  subprocess.call('firewall-cmd  --add-port=%s/tcp --permanent'%(str(port).strip()),shell=True)
  subprocess.call('firewall-cmd --reload',shell=True)



class MultiplePorts(object):
   def __init__(self):
     self.ListeningPortList=[]
     self.FlagOfQuit=False

   def __openPort(self,port):
      configFireallRule(port)
      s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
      s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
      
      portIsListening=checkPortState(port=port)['RetCode']
      if portIsListening != 0:
         s.bind(('0.0.0.0',port))
         s.listen(1)
         self.ListeningPortList.append(s)
         
         while not self.FlagOfQuit:
            a,b=s.accept()
            a.sendall('bye')
            a.close()
   def openPort(self,port):
       ThreadObj=threading.Thread(target=self.__openPort,args=[port])
       ThreadObj.start()

selfIP=sys.argv[1]

obj=MultiplePorts()
with open(r'host_listening_ports.txt',mode='r') as f:
   for line in f:
      line=line.strip()
      try:
         tmpIP,tmpPort=line.split()
         if tmpIP != selfIP:
             continue
         obj.openPort(int(tmpPort))
         sleep (0.05)
      except:
        pass
   sleep (8)

ssh_port=os.environ['SSH_CONNECTION'].split()[-1].strip()
configFireallRule(int(ssh_port))


daemonSock=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
daemonSock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
configFireallRule(18888)

try:
   daemonSock.bind(('0.0.0.0',18888))
   daemonSock.listen(1)
   while True:
       a,b=daemonSock.accept()
       a.close()
       daemonSock.close()
       obj.FlagOfQuit=True
       break
except:
   pass

SelfPID=os.getpid()
print (SelfPID)
subprocess.call('kill -9 %s'%(str(SelfPID), ),shell=True)
