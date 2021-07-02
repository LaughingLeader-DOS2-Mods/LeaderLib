set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\optionsSettings_c.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\optionsSettings_c.swf"
set SCRIPT_FOLDER=%~dp0

%JPEXS% -replace %SOURCE% %TARGET% optionsSettings_c_fla.MainTimeline "%SCRIPT_FOLDER%optionsSettings_c\optionsSettings_c_fla\MainTimeline.as" optionsSettings_c_fla.overview_mc_1 "%SCRIPT_FOLDER%optionsSettings_c\optionsSettings_c_fla\overview_mc_1.as" Menu_button "%SCRIPT_FOLDER%optionsSettings_c\Menu_button.as" SelectorMC "%SCRIPT_FOLDER%optionsSettings_c\SelectorMC.as" SliderComp "%SCRIPT_FOLDER%optionsSettings_c\SliderComp.as"