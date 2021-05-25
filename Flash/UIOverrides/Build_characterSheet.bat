set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\characterSheet.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\characterSheet.swf"
set SCRIPT_FOLDER=%~dp0

%JPEXS% -replace %SOURCE% %TARGET% characterSheet_fla.customStatsHolder_14 "%SCRIPT_FOLDER%characterSheet\characterSheet_fla\customStatsHolder_14.as" characterSheet_fla.MainTimeline "%SCRIPT_FOLDER%characterSheet\characterSheet_fla\MainTimeline.as" characterSheet_fla.stats_1 "%SCRIPT_FOLDER%characterSheet\characterSheet_fla\stats_1.as" StatCategory "%SCRIPT_FOLDER%characterSheet\StatCategory.as"