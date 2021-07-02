set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\statsPanel_c.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\statsPanel_c.swf"
set SCRIPT_FOLDER=%~dp0

%JPEXS% -replace %SOURCE% %TARGET% statsPanel_c_fla.MainTimeline "%SCRIPT_FOLDER%\statsPanel_c_fla\MainTimeline.as" Talent "%SCRIPT_FOLDER%\Talent.as" CustomStat "%SCRIPT_FOLDER%\CustomStat.as"