set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\optionsSettings.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\optionsSettings.swf"
set SCRIPT_FOLDER=%~dp0

%JPEXS% -replace %SOURCE% %TARGET% optionsSettings_fla.MainTimeline "%SCRIPT_FOLDER%optionsSettings\optionsSettings_fla\MainTimeline.as" optionsSettings_fla.overview_mc_1 "%SCRIPT_FOLDER%optionsSettings\optionsSettings_fla\overview_mc_1.as" Menu_button "%SCRIPT_FOLDER%optionsSettings\Menu_button.as" Selector "%SCRIPT_FOLDER%optionsSettings\Selector.as" SliderComp "%SCRIPT_FOLDER%optionsSettings\SliderComp.as" Label "%SCRIPT_FOLDER%optionsSettings\Label.as" Checkbox "%SCRIPT_FOLDER%optionsSettings\Checkbox.as" DropDown "%SCRIPT_FOLDER%optionsSettings\DropDown.as" LS_Classes.LSSlider "%SCRIPT_FOLDER%optionsSettings\LS_Classes\LSSlider.as"