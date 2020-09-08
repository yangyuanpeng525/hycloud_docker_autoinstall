#!/bin/bash
SOFT_base_FILE="/TRS/ansible-hy/AutoInstall"
SOFT_hy_FILE="/TRS/ansible-hy/hyapp"
SOFT_trs_FILE="/TRS/ansible-hy/trsapp"

cd $SOFT_base_FILE; ls | grep install > base.txt ;  for i in `cat base.txt`;  do  /bin/cp -rf  $i/* .; rm -rf $i; done; rm -rf base.txt
cd $SOFT_trs_FILE; ls | grep install > trs.txt ;  for i in `cat trs.txt`;  do  /bin/cp -rf  $i/* .; rm -rf $i; done; rm -rf trs.txt
cd $SOFT_hy_FILE; ls | grep install > hy.txt ;  for i in `cat hy.txt`;  do  /bin/cp -rf  $i/* .; rm -rf $i; done; rm -rf hy.txt

