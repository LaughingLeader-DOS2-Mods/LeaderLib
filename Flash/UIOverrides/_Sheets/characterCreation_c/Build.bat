set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\characterCreation_c.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\characterCreation_c.swf"
set SCRIPT_FOLDER=%~dp0
%JPEXS% -replace %SOURCE% %TARGET% characterCreation_c_fla.MainTimeline "%SCRIPT_FOLDER%characterCreation_c\characterCreation_c_fla\MainTimeline.as" characterCreation_c_fla.talentsMC_25 "%SCRIPT_FOLDER%characterCreation_c\characterCreation_c_fla\talentsMC_25.as" tagTalent "%SCRIPT_FOLDER%\tagTalent.as"