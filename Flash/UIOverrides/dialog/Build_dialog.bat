set JPEXS="%JPEXS_PATH%\ffdec.bat"
set SOURCE="%DOS2DE_EXTRACTED_PATH%\Public\Game\GUI\dialog.swf"
set TARGET="%DOS2_PATH%\DefEd\Data\Public\LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9\GUI\dialog.swf"
set SCRIPT_FOLDER=%~dp0

%JPEXS% -replace %SOURCE% %TARGET% TextComp "%SCRIPT_FOLDER%dialog\TextComp.as" LS_Classes.textHelpers "%SCRIPT_FOLDER%dialog\textHelpers.as"