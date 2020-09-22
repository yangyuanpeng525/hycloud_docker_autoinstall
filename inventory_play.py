#python2
import os
import configparser
import subprocess

# ansible-playbook -i /TRS/ansible-hy/inventory  /TRS/ansible-hy/install_elasticsearch.yml

#workpath = "/TRS/HyCloud_devops"
workpath = "/TRS/ansible-hy"

BaseFolder = os.getcwd()

SectionDict = {}
SectionDict_app = {}
SectionDict_var = {}
SectionDict_app_full = {}


def ParseFile(filename=None):
    config = configparser.ConfigParser()
    config.read(filename)

    TmpSectionList = config.sections()
    # print(TmpSectionList)
    for all_section in TmpSectionList:
        SectionDict[all_section] = config.items(all_section)
    # print(SectionDict)
    for tmp_section in TmpSectionList:
        tmp_section = tmp_section.strip()
        if ":var" in tmp_section:
            SectionDict_var[tmp_section] = SectionDict[tmp_section]
        else:
            # print(section)
            # print(SectionDict[section])
            SectionDict_app[tmp_section] = SectionDict[tmp_section]
    print("inventory分类完成")
    for section in SectionDict_app:
        # print(section+":var")
        # section_var = str(section+":vars")
        # print(section_var)
        # print(SectionDict_var)
        # print(SectionDict_var[section_var])
        for section_var in SectionDict_var:
            # print(section_var)
            if section+":vars" == section_var:
                # print(section_var)
                SectionDict_app_full[section] = SectionDict_app[section]
                SectionDict_app_full[section_var] = SectionDict_var[section_var]
                with open(os.path.join("/TRS/yyp/python/tmp", "inventory"), 'w') as f:
                    # f.write(SectionDict_app_full)
                    for data in SectionDict_app_full:
                        # print(data)
                        f.write("[%s]\n" % data)
                        for value in SectionDict_app_full[data]:
                            # f.write(str(value)+"\n")
                            if ":var" in data:
                                f.write("=".join(value)+'\n')
                            else:
                                f.write(":".join(value) + '\n')

                    for data in SectionDict_app_full:
                        if ":var" not in data:
                            inventory = 'inventory'
                            yaml_file = "install_"+data+".yml"
                            # print(inventory)
                            # print(yaml_file)
                            # subprocess.call("cd %s" % workpath, shell=True)
                            # subprocess.call('pwd', shell=True)
                            subprocess.call("ansible-playbook -i %s  %s" % (inventory, yaml_file), cwd=workpath, shell=True)
                            print("执行命令：ansible-playbook -i %s  %s\n" % (inventory, yaml_file))
        SectionDict_app_full.clear()
        # print(SectionDict_app_full)
if __name__ == "__main__":
    for TmpBasePath, TmpFolders, TmpFiles in os.walk(os.path.join(BaseFolder, 'tmp')):
        if TmpBasePath != os.path.join(BaseFolder, 'tmp'):
            continue
        for file in TmpFiles:
            if 'inventory' not in file:
                continue
            ParseFile(os.path.join("/TRS/yyp/python/tmp", file))
    #         ParseFile(os.path.join(TmpBasePath, file))
    # ParseFile(os.path.join("/TRS/yyp/python/tmp", "inventory-in-0"))