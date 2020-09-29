#!/usr/bin/env python3.6
# -*- coding:UTF-8 -*-

import os
import ConfigParser
import subprocess

workpath = "/TRS/HyCloud_devops"
# workpath = "/TRS/ansible-hy"

BaseFolder = os.getcwd()

#存放所有组名+：var
SectionDict = {}
#存放组名
SectionDict_app = {}
#存放：var
SectionDict_var = {}
#存放每次单独执行的组名+：var
SectionDict_app_full = {}
#存放trs应用,基础跑完在跑
SectionDict_trs = {}
#存放海云应用，基础和trs跑完在跑
SectionDict_hy = {}
#将nginx单独存放
SectionDict_nginx = {}
#将elasticsearch单独存放
SectionDict_elasticsearch = {}

#trs应用列表
trs_list = ["ids", "mas", "ids_net", "wechat", "trsweibo"]
#hy应用列表
hy_list = ["iip", "igi", "igs", "ipm", "igi_net"]
#安装所有trs应用的数
trs_num = 0
#安装所有海云应用的数
hy_num = 0

#inventory分类
inventory_base = "inventory-base"
inventory_trs = "inventory-trs"
inventory_hy = "inventory-hy"


#定义函数，执行基础
def ParseFile(filename=None):
    config = ConfigParser.ConfigParser()
    config.read(filename)
    global SectionDict_hy
    global SectionDict_trs

    TmpSectionList = config.sections()
    # print(TmpSectionList)
    for all_section in TmpSectionList:
        SectionDict[all_section] = config.items(all_section)
    # print(SectionDict)
    for tmp_section in TmpSectionList:
        tmp_section = tmp_section.strip()
        # if tmp_section == "mariadb":
        #     print(tmp_section)
        #     print("*" * 100)
        # if tmp_section == "redis":
        # print(tmp_section)
        # print("*" * 100)

        if "ckm" in tmp_section:
            continue
        if "logstash" in tmp_section:
            continue
        if ":vars" in tmp_section:
            SectionDict_var[tmp_section] = SectionDict[tmp_section]
        else:
            # print(section)
            # print(SectionDict[section])
            SectionDict_app[tmp_section] = SectionDict[tmp_section]
    print("inventory分类完成")
    print(SectionDict_app)
    print(SectionDict_var)

#先取出数据库
    with open(os.path.join(workpath, "inventory_mariadb"), 'w') as f:
        f.write("[mariadb]" + "\n")
        f.write(":".join(SectionDict_app["mariadb"][0]) + '\n')
        # f.write(SectionDict_app["mariadb"])
        SectionDict_app.pop("mariadb")
    print("执行命令：ansible-playbook -i inventory_mariadb install_mariadb.yml")
    mariadb_result = subprocess.call("ansible-playbook -i inventory_mariadb install_mariadb.yml ", cwd=workpath, shell=True)
    if mariadb_result != 0:
        exit(2)
        return "mariadb"
#安装nginx
    with open(os.path.join(workpath, "inventory_nginx"), 'w') as f:
        f.write("[nginx]" + "\n")
        f.write(":".join(SectionDict_app["nginx"][0]) + '\n')
        # f.write(SectionDict_app["mariadb"])
        # SectionDict_app.pop("mariadb")
    print("执行命令：ansible-playbook -i inventory_nginx install_nginx.yml")
    nginx_result = subprocess.call("ansible-playbook -i inventory_nginx install_nginx.yml ", cwd=workpath, shell=True)
    if nginx_result != 0:
        exit(2)
        return "nginx"
#取出组名
    for section in SectionDict_app:
        # if section == "mariadb":
        #     print(section)
        #     print("-" * 100)
        # if section == "redis":
        print("组名-" + section)
        print("-" * 100)
        # print("组名")
#trs应用后装
        if section in trs_list:
            global trs_num
            # global SectionDict_trs
            # global SectionDict_trs_list
            trs_num += 1
            tmp_trs = (section, SectionDict_app[section])
            tmp_trs_var = (section+":vars", SectionDict_var[section+":vars"])
            SectionDict_trs_list = []
            SectionDict_trs_list.append(tmp_trs)
            SectionDict_trs_list.append(tmp_trs_var)
            SectionDict_trs[trs_num] = SectionDict_trs_list
            del tmp_trs
            del tmp_trs_var
            # SectionDict_trs_list.clear()
            continue
#海云应用后装
        if section in hy_list:
            global hy_num
            # global SectionDict_hy
            # global SectionDict_hy_list
            hy_num += 1
            tmp_hy = (section, SectionDict_app[section])
            tmp_hy_var = (section + ":vars", SectionDict_var[section + ":vars"])
            SectionDict_hy_list = []
            SectionDict_hy_list.append(tmp_hy)
            SectionDict_hy_list.append(tmp_hy_var)
            SectionDict_hy[hy_num] = SectionDict_hy_list
            del tmp_hy
            del tmp_hy_var
            # SectionDict_hy_list.clear()
            continue
#取出：var组名
        for section_var in SectionDict_var:
            print("组名-" + section)
            print("-" * 100)
#组名与vars匹配，通过进行下一步
            if section+":vars" == section_var:
#拿到组名对应的vars
                SectionDict_app_full[section] = SectionDict_app[section]
                SectionDict_app_full[section_var] = SectionDict_var[section_var]
#判断，如是trs 和 海云应用，添加nginx + nginx:vars组
                if section in trs_list or section in hy_list or "rabbitmq" in section:
                    SectionDict_app_full["nginx"] = SectionDict_app["nginx"]
                    SectionDict_app_full["nginx:vars"] = SectionDict_var["nginx:vars"]
#将nginx组单独拿出来
                if section == "nginx":
                    print("A" * 100)
                    if "nginx" not in SectionDict_nginx:
                        SectionDict_nginx["nginx"] = SectionDict_app["nginx"]
                        SectionDict_nginx["nginx:vars"] = SectionDict_var["nginx:vars"]
#将elasticsearch组单独拿出来
                if "elasticsearch" in SectionDict_app:
                    if "elasticsearch" not in SectionDict_elasticsearch:
                        SectionDict_elasticsearch["elasticsearch"] = SectionDict_app["elasticsearch"]
                        SectionDict_elasticsearch["elasticsearch:vars"] = SectionDict_var["elasticsearch:vars"]
#写入inventory，组名+var组
                with open(os.path.join(workpath, "inventory_"+"%s") % section, 'w') as f:
                    if section == "nginx":
                        print("写入nginx" + "S" * 100)
                        print(SectionDict_app_full)
                    # f.write(SectionDict_app_full)
                    for data in SectionDict_app_full:
                        # print(data)
                        f.write("[%s]\n" % data)
                        for value in SectionDict_app_full[data]:
                            # print(value)
                            # f.write(str(value)+"\n")
                            if ":vars" in data:
                                f.write("=".join(value)+'\n')
                            else:
                                f.write(":".join(value) + '\n')
#匹配对应的playbook，install_XXX.yml,inventory
#先跑mariadb

                for data in SectionDict_app_full:
                    if data == "mariadb":
                        # print("a" * 100)
                        continue
                    if data == "nginx":
                        # print("a" * 100)
                        continue
                    if ":vars" not in data:
                        # inventory = 'inventory-'+data
                        # print(data, "-" * 100)

                        yaml_file = "install_"+data+".yml"
                        # print("-" * 20)
                        print("执行命令：ansible-playbook -i inventory_%s %s" % (data, yaml_file))
                        base_result = subprocess.call("ansible-playbook -i inventory_%s  %s" % (data, yaml_file), cwd=workpath, shell=True)
                        if base_result != 0:
                            exit(2)
                            return data
#每次执行完ansible-playbook，清空字典，保证每次生成的inventory为干净的inventory
                SectionDict_app_full.clear()
#清除本次的组名
    SectionDict_app.clear()
    SectionDict_var.clear()
    # return 0

#trs应用
def trs_run():
#执行trs
    for app in SectionDict_trs:
        # print(SectionDict_trs[app])
        subprocess.call(">%s" % inventory_trs, cwd=workpath, shell=True)
        for group, groupvalue in SectionDict_trs[app]:
            # print(group, groupvalue)
            with open(os.path.join(workpath, inventory_trs), 'a') as f:
                f.write("[%s]\n" % group)
                for i in groupvalue:
                    if ":var" in group:
                        f.write("=".join(i) + "\n")
                    else:
                        f.write(":".join(i) + "\n")
            if ":vars" not in group:
                yaml_file = "install_"+group+".yml"
                # print(yaml_file)
#写入nginx组
        with open(os.path.join(workpath, inventory_trs), 'a') as f:
            f.write("[nginx]\n")
            # print(SectionDict_app["nginx"])
            f.write(":".join(SectionDict_nginx["nginx"][0]) + "\n")
            f.write("[nginx:vars]\n")
            f.write("=".join(SectionDict_nginx["nginx:vars"][0]) + "\n")
            print("执行命令：ansible-playbook -i %s  %s" % (inventory_trs, yaml_file))
        trs_result = subprocess.call("ansible-playbook -i %s  %s" % (inventory_trs, yaml_file), cwd=workpath, shell=True)
        if trs_result != 0:
            exit(2)
            return group
    # return 0
        # break

#海云应用
def hy_run():
#执行hy
    for app in SectionDict_hy:
        # print(SectionDict_trs[app])
        subprocess.call(">%s" % inventory_hy, cwd=workpath, shell=True)
        for group, groupvalue in SectionDict_hy[app]:
            # print(group, groupvalue)
            with open(os.path.join(workpath, inventory_hy), 'a') as f:
                f.write("[%s]\n" % group)
                for i in groupvalue:
                    if ":var" in group:
                        f.write("=".join(i) + "\n")
                    else:
                        f.write(":".join(i) + "\n")
                if "iip:vars" in group:
                    f.write("[elasticsearch]\n")
                    f.write(":".join(SectionDict_elasticsearch["elasticsearch"][0]) + "\n")
                    # f.write("[elasticsearch:vars]\n")
                    # f.write("=".join(SectionDict_elasticsearch["elasticsearch:vars"][0]) + "\n")
            if ":vars" not in group:
                yaml_file = "install_"+group+".yml"
                # print(yaml_file)
#写入nginx组
        with open(os.path.join(workpath, inventory_hy), 'a') as f:
            f.write("[nginx]\n")
            # print(SectionDict_app["nginx"])
            f.write(":".join(SectionDict_nginx["nginx"][0]) + "\n")
            # f.write("[nginx:vars]\n")
            # f.write("=".join(SectionDict_nginx["nginx:vars"][0]) + "\n")
            print("执行命令：ansible-playbook -i %s  %s" % (inventory_hy, yaml_file))
        hy_result = subprocess.call("ansible-playbook -i %s  %s" % (inventory_hy, yaml_file), cwd=workpath, shell=True)
        if hy_result != 0:
            exit(2)
            return group
    # return 0
        # break


#主函数
if __name__ == "__main__":
#安装docker
    print("-" * 20 + "开始为所有主机安装docker环境" + "-" * 20)
    print("执行命令：ansible-playbook -i inventory-all install_docker.yml")
    docker_result = subprocess.call("ansible-playbook -i inventory-all install_docker.yml", cwd=workpath, shell=True)
    if docker_result != 0:
        print("docker_result:" + str(docker_result))
        exit(2)

#拿到目录下的所有文件
    print("-" * 20 + "开始安装基础应用" + "-" * 20)
    for TmpBasePath, TmpFolders, TmpFiles in os.walk(os.path.join(BaseFolder, 'tmp')):
        for file in TmpFiles:
#找出inventory-in-X配置文件
            if 'inventory-in-' not in file:
                continue
            print("读取inventory文件：" + os.path.join(BaseFolder, "tmp", file))
#调用函数，安装基础
            ParseFile(os.path.join(BaseFolder, "tmp", file))
            # ParseFile(os.path.join(BaseFolder, "tmp", file))
            # if result != 0:
            #     print("result:" + str(result))
            #     exit(2)


#trs
    print("-" * 20 +"开始安装trs应用" + "-" * 20)
    trs_run()

#hy
    print("-" * 20 +"开始安装海云应用" + "-" * 20)
    hy_run()

