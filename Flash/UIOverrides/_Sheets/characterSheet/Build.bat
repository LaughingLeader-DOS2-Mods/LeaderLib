set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\characterSheet.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\characterSheet.swf"
set SCRIPT_FOLDER=%~dp0
rem  LS_Classes.scrollListGrouped "%SCRIPT_FOLDER%\LS_Classes\scrollListGrouped.as"
rem  LS_Classes.listDisplay "G:\SourceControlGenerator\Data\Divinity Original Sin 2 - Definitive Edition\Projects\LeaderLib\Flash\UIExtensions\src\LS_Classes\listDisplay.as"
%JPEXS% -replace %SOURCE% %TARGET% characterSheet_fla.customStatsHolder_14 "%SCRIPT_FOLDER%\characterSheet_fla\customStatsHolder_14.as" characterSheet_fla.MainTimeline "%SCRIPT_FOLDER%\characterSheet_fla\MainTimeline.as" characterSheet_fla.stats_1 "%SCRIPT_FOLDER%\characterSheet_fla\stats_1.as" StatCategory "%SCRIPT_FOLDER%\StatCategory.as" CustomStat "%SCRIPT_FOLDER%\CustomStat.as" characterSheet_fla.pointsAvailable_56 "%SCRIPT_FOLDER%\characterSheet_fla\pointsAvailable_56.as" skillEl "%SCRIPT_FOLDER%\skillEl.as" Talent "%SCRIPT_FOLDER%\Talent.as" characterSheet_fla.talentsHolder_11 "%SCRIPT_FOLDER%\characterSheet_fla\talentsHolder_11.as"