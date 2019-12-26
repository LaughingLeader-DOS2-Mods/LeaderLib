LeaderLib = {
	Main = {},
	Settings = {},
	Common = {},
}

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib__Common.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Main.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GlobalSettings.lua");

--Ext.NewQuery(LeaderLib.StringToVersion_Query, "LeaderLib_Ext_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build");
--Ext.NewCall(LeaderLib.PrintAttributes, "LeaderLib_Ext_PrintAttributes", "(CHARACTERGUID)_Char");