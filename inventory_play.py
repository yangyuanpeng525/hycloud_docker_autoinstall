#!/usr/bin/env python3.6
# -*- coding:UTF-8 -*-

import os
import ConfigParser
import subprocess

workpath = "/TRS/HyCloud_devops"

BaseFolder = os.getcwd()

# 存放所有组名+：var
SectionDict = {}
# 存放组名
SectionDict_app = {}
# 存放：var
SectionDict_var = {}
# 存放每次单独执行的组名+：var
SectionDict_app_full = {}
# 存放trs应用,基础跑完在跑
SectionDict_trs = {}
# 存放海云应用，基础和trs跑完在跑
SectionDict_hy = {}
# 将nginx单独存放
SectionDict_nginx = {}
SectionDict_nginx_net = {}
# 将elasticsearch单独存放
SectionDict_elasticsearch = {}

#基础应用需要提前执行的
base_first_run = ["mariadb_net", "mariadb", "mariadb_replication", "nginx", "nginx_net"]
# trs应用列表
trs_list = ["ids", "mas", "ids_net", "wechat", "trsweibo"]
# hy应用列表
hy_list = ["iip", "igi", "igs", "ipm", "igi_net"]
# 安装所有trs应用的数
trs_num = 0
# 安装所有海云应用的数
hy_num = 0

# 先执行mariadb，nginx

def run_first(group=None):
    with open(os.path.join(workpath, "inventory_%s") % (group), 'w') as f:
        f.write("[" + group + "]" + "\n")
        f.write(":".join(SectionDict_app[group][0]) + '\n')
    print("执行命令：ansible-playbook -i inventory_%s install_%s.yml" % (group, group))
    result = subprocess.call("ansible-playbook -i inventory_%s install_%s.yml" % (group, group), cwd=workpath,
                                     shell=True)
    if result != 0:
        exit(2)

# 定义函数，执行基础
def ParseFile(filename=None):
    config = ConfigParser.ConfigParser()
    config.read(filename)
    global SectionDict_hy
    global SectionDict_trs

    TmpSectionList = config.sections()

    for all_section in TmpSectionList:
        SectionDict[all_section] = config.items(all_section)

    for tmp_section in TmpSectionList:
        tmp_section = tmp_section.strip()

        if "ckm" in tmp_section:
            continue
        if "logstash" in tmp_section:
            continue
        if ":vars" in tmp_section:
            SectionDict_var[tmp_section] = SectionDict[tmp_section]
        else:
            SectionDict_app[tmp_section] = SectionDict[tmp_section]
    print(filename + "分类完成")

#基础中需要先安装
    for base_app in base_first_run:
        if base_app in SectionDict_app:
            run_first(group=base_app)
# 取出组名
    for section in SectionDict_app:
        # trs应用后装
        if section in trs_list:
            global trs_num
            trs_num += 1
            tmp_trs = (section, SectionDict_app[section])
            SectionDict_trs_list = []
            SectionDict_trs_list.append(tmp_trs)
            SectionDict_trs[trs_num] = SectionDict_trs_list
            del tmp_trs
            continue
        # 海云应用后装
        if section in hy_list:
            global hy_num
            hy_num += 1
            tmp_hy = (section, SectionDict_app[section])
            SectionDict_hy_list = []
            SectionDict_hy_list.append(tmp_hy)
            SectionDict_hy[hy_num] = SectionDict_hy_list
            del tmp_hy
            continue
# 取出：var组名
        for section_var in SectionDict_var:
            if section + ":vars" == section_var:
                # 拿到组名对应的vars
                SectionDict_app_full[section] = SectionDict_app[section]
                SectionDict_app_full[section_var] = SectionDict_var[section_var]
                # 判断，如是trs 和 海云应用，添加nginx + nginx:vars组
                if section in trs_list or section in hy_list or "rabbitmq" in section:
                    SectionDict_app_full["nginx"] = SectionDict_app["nginx"]
                    SectionDict_app_full["nginx:vars"] = SectionDict_var["nginx:vars"]
                # 将nginx组单独拿出来
                    if "nginx" not in SectionDict_nginx:
                        SectionDict_nginx["nginx"] = SectionDict_app["nginx"]
                        SectionDict_nginx["nginx:vars"] = SectionDict_var["nginx:vars"]
                    if "nginx_net" not in SectionDict_nginx_net:
                        SectionDict_nginx_net["nginx_net"] = SectionDict_app["nginx_net"]
                        SectionDict_nginx_net["nginx_net:vars"] = SectionDict_var["nginx_net:vars"]
                # 将elasticsearch组单独拿出来
                if "elasticsearch" in SectionDict_app:
                    if "elasticsearch" not in SectionDict_elasticsearch:
                        SectionDict_elasticsearch["elasticsearch"] = SectionDict_app["elasticsearch"]
                        SectionDict_elasticsearch["elasticsearch:vars"] = SectionDict_var["elasticsearch:vars"]
                if "elasticsearch_cluster" in SectionDict_app:
                    if "elasticsearch_cluster" not in SectionDict_elasticsearch:
                        SectionDict_elasticsearch["elasticsearch_cluster"] = SectionDict_app["elasticsearch_cluster"]
                        SectionDict_elasticsearch["elasticsearch_cluster:vars"] = SectionDict_var["elasticsearch_cluster:vars"]
                # 写入inventory，组名+var组
                with open(os.path.join(workpath, "inventory_" + "%s") % section, 'w') as f:
                    for data in SectionDict_app_full:
                        f.write("[%s]\n" % data)
                        for value in SectionDict_app_full[data]:
                            if ":vars" in data:
                                f.write("=".join(value) + '\n')
                            else:
                                f.write(":".join(value) + '\n')

# 匹配对应的playbook，install_XXX.yml,inventory
# 先跑mariadb
                for data in SectionDict_app_full:
                    if "mariadb" in data:
                        continue
                    if "nginx" in data:
                        continue
                    if ":vars" not in data:
                        yaml_file = "install_" + data + ".yml"
                        print("执行命令：ansible-playbook -i inventory_%s %s" % (data, yaml_file))
                        base_result = subprocess.call("ansible-playbook -i inventory_%s  %s" % (data, yaml_file),
                                                      cwd=workpath, shell=True)
                        if base_result != 0:
                            exit(2)
                # 每次执行完ansible-playbook，清空字典，保证每次生成的inventory为干净的inventory
                SectionDict_app_full.clear()
    # 清除本次inventory-in-X的组名
    SectionDict_app.clear()
    SectionDict_var.clear()


# trs应用
def trs_run():
    # 执行trs
    for app in SectionDict_trs:
        for group, groupvalue in SectionDict_trs[app]:
            with open(os.path.join(workpath, "inventory_trs_" + group), 'a') as f:
                f.write("[%s]\n" % group)
                for i in groupvalue:
                    if ":var" in group:
                        f.write("=".join(i) + "\n")
                    else:
                        f.write(":".join(i) + "\n")
            if ":vars" not in group:
                yaml_file = "install_" + group + ".yml"

        # 写入nginx组
        with open(os.path.join(workpath, "inventory_trs_" + group), 'a') as f:
            if group == "ids_net":
                f.write("[nginx_net]\n")
                f.write(":".join(SectionDict_nginx_net["nginx_net"][0]) + "\n")
            else:
                f.write("[nginx]\n")
                f.write(":".join(SectionDict_nginx["nginx"][0]) + "\n")
            print("执行命令：ansible-playbook -i %s  %s" % ("inventory_trs_" + group, yaml_file))
        trs_result = subprocess.call("ansible-playbook -i %s  %s" % ("inventory_trs_" + group, yaml_file), cwd=workpath,
                                     shell=True)
        if trs_result != 0:
            exit(2)

# 海云应用
def hy_run():
    # 执行hy
    for app in SectionDict_hy:
        for group, groupvalue in SectionDict_hy[app]:
            with open(os.path.join(workpath, "inventory_hy_" + group), 'a') as f:
                f.write("[%s]\n" % group)
                for i in groupvalue:
                    f.write(":".join(i) + "\n")
                if "iip" in group:
                    if "elasticsearch" in SectionDict_elasticsearch:
                        f.write("[elasticsearch]\n")
                        f.write(":".join(SectionDict_elasticsearch["elasticsearch"][0]) + "\n")
                    elif "elasticsearch_cluster" in SectionDict_elasticsearch:
			#iip的logstash默认elasticsearch组
                        f.write("[elasticsearch]\n")
#                        f.write("[elasticsearch_cluster]\n")
                        f.write(":".join(SectionDict_elasticsearch["elasticsearch_cluster"][0]) + "\n")
                yaml_file = "install_" + group + ".yml"
# 写入nginx组
        with open(os.path.join(workpath, "inventory_hy_" + group), 'a') as f:
            if group == "igi_net":
                f.write("[nginx_net]\n")
                f.write(":".join(SectionDict_nginx_net["nginx_net"][0]) + "\n")
            else:
                f.write("[nginx]\n")
                f.write(":".join(SectionDict_nginx["nginx"][0]) + "\n")
            print("执行命令：ansible-playbook -i %s  %s" % ("inventory_hy_" + group, yaml_file))
        hy_result = subprocess.call("ansible-playbook -i %s  %s" % ("inventory_hy_" + group, yaml_file), cwd=workpath, shell=True)
        if hy_result != 0:
            exit(2)

# 主函数
if __name__ == "__main__":
    # 安装docker
    print("-" * 20 + "开始为所有主机安装docker环境" + "-" * 20)
    print("执行命令：ansible-playbook -i inventory-all install_docker.yml")
    docker_result = subprocess.call("ansible-playbook -i inventory-all install_docker.yml", cwd=workpath, shell=True)
    if docker_result != 0:
        print("docker_result:" + str(docker_result))
        exit(2)

    # 拿到目录下的所有文件
    print("-" * 20 + "开始安装基础应用" + "-" * 20)
    for TmpBasePath, TmpFolders, TmpFiles in os.walk(os.path.join(BaseFolder, 'tmp')):
        for file in TmpFiles:
            # 找出inventory-in-X配置文件
            if 'inventory-in-' not in file:
                continue
            print("读取inventory文件：" + os.path.join(BaseFolder, "tmp", file))
            # 调用函数，安装基础
            ParseFile(os.path.join(BaseFolder, "tmp", file))
# TRS
    print("-" * 20 + "开始安装trs应用" + "-" * 20)
    trs_run()

# HyCloud
    print("-" * 20 + "开始安装海云应用" + "-" * 20)
    hy_run()


