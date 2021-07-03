import os
import sys
from pathlib import Path
from typing import Dict,List
import re
import subprocess

script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
os.chdir(script_dir)

JPEXS = Path(os.environ["JPEXS_PATH"]).joinpath("ffdec.bat")
DOS2DE = Path(os.environ["DOS2_PATH"])
SOURCE_FILES = Path(os.environ["DOS2DE_EXTRACTED_PATH"]).joinpath("Public/Game/GUI/")
OUTPUT = DOS2DE.joinpath("DefEd/Data/Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/")

targets = [
    "characterCreation",
    "characterCreation_c",
    "characterSheet",
    "statsPanel_c",
]

package_pattern = re.compile("package ([^\s]+)", re.IGNORECASE | re.MULTILINE)
class_pattern = re.compile("class ([^\s]+)", re.IGNORECASE | re.MULTILINE)

class CompileData:
    def __init__(self, id):
        self.ID = id
        self.SourceFolder = script_dir.joinpath(id)
        self.InputFile = SOURCE_FILES.joinpath(id).with_suffix(".swf")
        self.OutputFile = OUTPUT.joinpath(id).with_suffix(".swf")
        self.Scripts:Dict[str,str] = {}
        self.find_scripts()
    
    def find_scripts(self):
        files:List[Path] = list(self.SourceFolder.rglob("*.as"))
        for p in files:
            text = p.read_text(encoding='utf-8')
            classId = ""
            if m := package_pattern.search(text):
                package = str(m.group(1)).strip()
                if package != "":
                    classId = package
            if m2 := class_pattern.search(text):
                if classId != "":
                    classId = "{}.{}".format(classId, m2.group(1))
                else:
                    classId = m2.group(1)
            
            if classId != "":
                self.Scripts[str(p.absolute())] = classId

command_template = '{} -replace {} {}'

for t in targets:
    data:CompileData = CompileData(t)
    if len(data.Scripts.values()) > 0:
        #print("Classes:{}".format(";".join(data.Scripts.values())))
        cmds = [str(JPEXS.absolute()),
            "-replace", 
            str(data.InputFile.absolute()),
            str(data.OutputFile.absolute())]
        for k,v in data.Scripts.items():
            cmds.append(v)
            cmds.append(k)
        #print(cmds)
        process = subprocess.Popen(cmds, 
            shell=True,
            universal_newlines=True,
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE)
        # Poll process for new output until finished
        while True:
            nextline = process.stdout.readline()
            if nextline == '' and process.poll() is not None:
                break
            sys.stdout.write(nextline)
            sys.stdout.flush()
        exitCode = process.returncode
        if exitCode != 0:
            print("Error compiling {}({}):\n{}.".format(data.ID, exitCode, process.communicate()))
        print("Replaced scripts in {} and saved to {}.".format(data.InputFile, data.OutputFile))