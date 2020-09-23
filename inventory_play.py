#python3
import os
import configparser
import subprocess

#workpath = "/TRS/HyCloud_devops"
workpath = "/TRS/ansible-hy"

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
# SectionDict_trs_list = []
#存放海云应用，基础和trs跑完在跑
SectionDict_hy = {}
# SectionDict_hy_list = []
#trs应用列表
trs_list = ["ids", "mas", "ids_net", "wechat", "trsweibo"]
#hy应用列表
hy_list = ["iip", "igi", "igs", "ipm", "igi_net"]
#安装所有trs应用的数
trs_num = 0
#安装所有海云应用的数
hy_num = 0
#
inventory_trs = "inventory-trs"
inventory_hy = "inventory-hy"
#定义函数，执行基础
def ParseFile(filename=None):
    config = configparser.ConfigParser()
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
        if ":vars" in tmp_section:
            SectionDict_var[tmp_section] = SectionDict[tmp_section]
        else:
            # print(section)
            # print(SectionDict[section])
            SectionDict_app[tmp_section] = SectionDict[tmp_section]
    print("inventory分类完成")
#取出组名
    for section in SectionDict_app:
#trs应用后装
        if section in trs_list:
            # SectionDict_trs[section] = SectionDict_app[section]
            # SectionDict_trs[section+":vars"] = SectionDict_var[section+":vars"]
            global trs_num
            # global SectionDict_trs
            # global SectionDict_trs_list
            trs_num += 1
            print(str(trs_num)+'-----trs')
            print(section)
            tmp_trs = (section, SectionDict_app[section])
            tmp_trs_var = (section+":vars", SectionDict_var[section+":vars"])
            SectionDict_trs_list = []
            SectionDict_trs_list.append(tmp_trs)
            SectionDict_trs_list.append(tmp_trs_var)
            # print(SectionDict_trs_list)
            SectionDict_trs[trs_num] = SectionDict_trs_list
            # print(trs_num, SectionDict_trs[trs_num])
            # print("ooooooooo")
            # print(SectionDict_trs)
            del tmp_trs
            del tmp_trs_var
            # SectionDict_trs_list.clear()
            # print(trs_num, SectionDict_trs[trs_num])
            continue
#海云应用后装
        if section in hy_list:
            # SectionDict_hy[section] = SectionDict_app[section]
            # SectionDict_hy[section+":vars"] = SectionDict_var[section+":vars"]
            global hy_num
            # global SectionDict_hy
            # global SectionDict_hy_list
            hy_num += 1
            print(str(hy_num)+"----hy")
            print(section)
            tmp_hy = (section, SectionDict_app[section])
            tmp_hy_var = (section + ":vars", SectionDict_var[section + ":vars"])
            SectionDict_hy_list = []
            SectionDict_hy_list.append(tmp_hy)
            SectionDict_hy_list.append(tmp_hy_var)
            SectionDict_hy[hy_num] = SectionDict_hy_list
            # print(hy_num,SectionDict_hy_list)
            # print("oooooooo")
            # print(SectionDict_hy)
            del tmp_hy
            del tmp_hy_var
            # SectionDict_hy_list.clear()
            continue
#取出：var组名
        for section_var in SectionDict_var:
#组名与vars匹配，通过进行下一步
            if section+":vars" == section_var:
#拿到组名对应的vars
                SectionDict_app_full[section] = SectionDict_app[section]
                SectionDict_app_full[section_var] = SectionDict_var[section_var]
#判断，如是trs 和 海云应用，添加nginx + nginx:vars组
                if section in trs_list or section in hy_list or "rabbitmq" in section:
                    SectionDict_app_full["nginx"] = SectionDict_app["nginx"]
                    SectionDict_app_full["nginx:vars"] = SectionDict_var["nginx:vars"]
#写入inventory，组名+var组
                with open(os.path.join("/TRS/ansible-hy", "inventory-%s") % section, 'w') as f:
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
                for data in SectionDict_app_full:
                    if ":vars" not in data:
                        inventory = 'inventory-'+data
                        yaml_file = "install_"+data+".yml"
                        print("---------------------------------------------------------------------------")
                        print("执行命令：ansible-playbook -i %s  %s\n" % (inventory, yaml_file))
                        #subprocess.call("ansible-playbook -i %s  %s" % (inventory, yaml_file), cwd=workpath, shell=True)
#每次执行完ansible-playbook，清空字典，保证每次生成的inventory为干净的inventory
                SectionDict_app_full.clear()
#取出trs 海云应用
    # print(
    #     "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    # print(SectionDict_hy)
    # print(
    #     "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    # print(SectionDict_hy)
    # return (SectionDict_trs, SectionDict_hy)

def trs_run():
#执行trs
    print("c" * 100)
    # print(SectionDict_hy)
    # print("c" * 100)
    # print(SectionDict_trs)
    # SectionDict_trs["nginx"] = SectionDict_app["nginx"]
    # SectionDict_trs["nginx:vars"] = SectionDict_var["nginx:vars"]
    for app in SectionDict_trs:
        # print(SectionDict_trs[app])
        subprocess.call(">inventory-trs", cwd=workpath, shell=True)
        for group, groupvalue in SectionDict_trs[app]:
            # print(group, groupvalue)
            with open(os.path.join("/TRS/ansible-hy", "inventory-trs"), 'a') as f:
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
        with open(os.path.join("/TRS/ansible-hy", "inventory-trs"), 'a') as f:
            f.write("[nginx]\n")
            # print(SectionDict_app["nginx"])
            f.write(":".join(SectionDict_app["nginx"][0]) + "\n")
            f.write("[nginx:vars]\n")
            f.write("=".join(SectionDict_var["nginx:vars"][0]) + "\n")
        subprocess.call("ansible-playbook -i inventory-trs  %s" % (yaml_file), cwd=workpath, shell=True)
        # break

# def hy_run():
# #执行trs
#     print("c" * 100)
#     # print(SectionDict_hy)
#     # print("c" * 100)
#     # print(SectionDict_trs)
#     # SectionDict_trs["nginx"] = SectionDict_app["nginx"]
#     # SectionDict_trs["nginx:vars"] = SectionDict_var["nginx:vars"]
#     for app in SectionDict_hy:
#         # print(SectionDict_trs[app])
#         subprocess.call(">%s" % inventory_hy, cwd=workpath, shell=True)
#         for group, groupvalue in SectionDict_hy[app]:
#             # print(group, groupvalue)
#             with open(os.path.join("/TRS/ansible-hy", inventory_hy), 'a') as f:
#                 f.write("[%s]\n" % group)
#                 for i in groupvalue:
#                     if ":var" in group:
#                         f.write("=".join(i) + "\n")
#                     else:
#                         f.write(":".join(i) + "\n")
#             if ":vars" not in group:
#                 yaml_file = "install_"+group+".yml"
#                 # print(yaml_file)
# #写入nginx组
#         with open(os.path.join("/TRS/ansible-hy", inventory_hy), 'a') as f:
#             f.write("[nginx]\n")
#             # print(SectionDict_app["nginx"])
#             f.write(":".join(SectionDict_app["nginx"][0]) + "\n")
#             f.write("[nginx:vars]\n")
#             f.write("=".join(SectionDict_var["nginx:vars"][0]) + "\n")
#         subprocess.call("ansible-playbook -i %s  %s" % (inventory_hy, yaml_file), cwd=workpath, shell=True)
#         # break

if __name__ == "__main__":
#    subprocess.call("ansible-playbook -i inventory-all install_docker.yml", cwd=workpath, shell=True)
#拿到目录下的所有文件
    for TmpBasePath, TmpFolders, TmpFiles in os.walk(os.path.join("/TRS/yyp/Ansible_Install_HyCloud", 'tmp')):
        for file in TmpFiles:
#找出inventory-in-X配置文件
            if 'inventory-in-' not in file:
                continue
            ParseFile(os.path.join("/TRS/yyp/python/tmp", file))
            print(os.path.join("/TRS/yyp/python/tmp", file))
    # print("ccccccccccccccccccccccccccccc")
    # print(SectionDict_hy)
    # print("ccccccccccccccccccccccccccccc")
    # print(SectionDict_trs)
    print("1" * 100)
    trs_run()
    # hy_run()

