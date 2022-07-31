import os
import sys
from pathlib import Path
from typing import Dict,List
import re
import subprocess
from alive_progress import alive_bar

script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
os.chdir(script_dir)
""" 
Environment Variables
#######
JPEXS_PATH
The path to the folder that has JPEXS and ffdec.bat, for overriding swf scripts.

DOS2_PATH
The root folder of Divinity: Original Sin 2

DOS2DE_EXTRACTED_PATH
The folder for wherever the DOS2DE paks were extracted to.
"""

JPEXS = Path(os.environ["JPEXS_PATH"]).joinpath("ffdec.bat")
SOURCE_FILES = Path(os.environ["DOS2DE_EXTRACTED_PATH"]).joinpath("Public/Game/GUI/")
DOS2 = Path(os.environ["DOS2_PATH"])
DOS2DE_PUBLIC = DOS2.joinpath("DefEd/Data/Public/")
OUTPUT = DOS2DE_PUBLIC.joinpath("LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/")

targets = [
    #"tooltip",
    "optionsSettings",
    "optionsSettings_c",
    "journal",
]

package_pattern = re.compile("package ([^\s]+)", re.IGNORECASE | re.MULTILINE)
class_pattern = re.compile("class ([^\s]+)", re.IGNORECASE | re.MULTILINE)

ignore_output_text = [
    "tagId",
    "Replace AS3",
    "EXPERIMENTAL"
]

class CompileData:
    def __init__(self, id):
        self.ID = id
        self.SourceFolder = script_dir.joinpath(id)
        self.InputFile = SOURCE_FILES.joinpath(id).with_suffix(".swf")
        self.OutputFile = OUTPUT.joinpath(id).with_suffix(".swf")
        self.OutputFile.parent.mkdir(parents=True, exist_ok=True)
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

script_data:List[CompileData] = []

for t in targets:
    data:CompileData = CompileData(t)
    if len(data.Scripts.values()) > 0:
        script_data.append(data)

with alive_bar(len(script_data)) as bar:
    for data in script_data:
        print("Replacing scripts in {} and saving to {}.".format(data.InputFile.name, str(data.OutputFile).replace(str(DOS2DE_PUBLIC) + "\\", "")))
        bar.text("Asking JPEXS for help...")
        cmds = [str(JPEXS.absolute()),
            "-cli", 
            "-replace", 
            str(data.InputFile.absolute()),
            str(data.OutputFile.absolute())]
        for k,v in data.Scripts.items():
            cmds.append(v)
            cmds.append(k)
        process = subprocess.Popen(cmds, 
            shell=True,
            universal_newlines=True,
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE)
        # Poll process for new output until finished
        #print("{}".format(subprocess.list2cmdline(cmds)))
        while True:
            nextline = process.stdout.readline()
            if nextline == '' and process.poll() is not None:
                break
            #Ignore all the garbage JPEXS prints
            if not any(x in nextline for x in ignore_output_text):
                sys.stdout.write(nextline)
                sys.stdout.flush()
        exitCode = process.returncode
        if exitCode != 0:
            print("Error compiling {}({}):\n{}.".format(data.ID, exitCode, process.communicate()))
        else:
            print("Successfully recompiled {}.".format(data.ID))
        bar()
print("All done.")