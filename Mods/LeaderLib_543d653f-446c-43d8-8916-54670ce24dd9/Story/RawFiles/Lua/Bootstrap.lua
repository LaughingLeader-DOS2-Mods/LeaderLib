Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "leaderLib_ext_main.lua");

Ext.NewQuery(leaderlib.string_to_version, "LeaderLib_Ext_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build");
Ext.NewCall(leaderlib.print_attributes, "LeaderLib_Ext_PrintAttributes", "(CHARACTERGUID)_Char");